def get_uid(line)
  uid = ''
  uid2 = ''
  begin
    start = line.rindex('uid=') + 'uid='.size
    stop = line.index('"', start) -1
    uid = line[start .. stop]
  rescue
  end
  # parse the sifi_uid, as we are scared
  begin
    start = line.index("sifi=") + "sifi=".size
    stop = line.index(" ", start)
    xs = line[start..stop].split(",")
    uid2 = xs[18]
  rescue
  end
  [uid, uid2]
end


LOGS = "/data/log/ads"

@days = (ARGV[0] || 30 ).to_i
@users = {}

puts "Genearting user hash maps"
IO.popen("find #{LOGS} -type f -mtime -#{@days} -exec zcat {} \\;") do |io|
  while line = io.gets
    next unless line.index("/ads/")
    uid1, uid2 = get_uid(line)
    if uid1 != uid2
      @users[uid2] ||= []
      @users[uid2] << uid1  unless @users[uid2].include?(uid1)
    end
  end
end

#puts @users.size
#puts @users.inspect
f = File.open("/data/doppelgaenger/doppelgaenger.mar", "w")
f.puts Marshal.dump(@users)
f.close

