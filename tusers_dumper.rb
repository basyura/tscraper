require 'rubygems'
require 'sequel'
require 'fastercsv'
require 'pstore'
require 'yaml'
require 'dump_conv_def'
require 'tusers_csv'

def to_pstore(dump_path , store_map) 
  store_map.each_pair{|key,value|
    PStore.new("#{dump_path}/#{key}.store").transaction{|store|
      sl = store[:root] ||= []
      sl.concat value
    }
  }
end

yaml = YAML.load_file("tusers_dump.yaml")

dump_csv  = yaml["dump_csv"]
dump_path = yaml["dump_path"]


sql = %Q! select * from users into outfile '#{dump_csv}' fields terminated by ',' ENCLOSED BY '"' ESCAPED BY '"' LINES TERMINATED BY '\n' !
#sql = "select * from users into outfile '#{dump_csv}' fields terminated by ',' ENCLOSED BY '\"' ESCAPED BY '\"' LINES TERMINATED BY '\\n' "

begin
  File.delete(dump_csv)
rescue
  puts "can't delete file : #{dump_csv}"
end

DB = Sequel.connect(yaml["connect_url"] , :encoding => yaml["connect_encoding"])
st_time = Time.now
DB.execute(sql)
puts "dump #{Time.now - st_time}"

st_time = Time.now
Dir.entries(dump_path).each {|e|
  next if e == "." || e == ".."
  File.delete(dump_path + "/" + e)
}
puts "delete dump files #{Time.now - st_time}"

st_time = Time.now
begin
puts "start convert"
print "S"
counter = 0
store_map = {}
#FasterCSV.foreach(dump_csv , :skip_blanks => true ){|csv|
TusersCSV.foreach(dump_csv){|csv|
#  print csv[0] + " " + csv[1] + " ... "
  counter += 1
  if counter % 10000 == 0
    print (counter / 10000).to_s
  elsif counter % 1000 == 0
    print "."
  end
  STDOUT.flush
  user =
  {
    :screen_name => csv[1],
    :uid => csv[2],
    :name => csv[3],
    :description => csv[4],
    :profile_image_url => csv[5],
    :url => csv[6],
    :utc_offset => csv[7].to_i,
    :time_zone => csv[8].to_i,
    :location => csv[9],
    :followers_count => csv[10].to_i,
    :friends_count => csv[11].to_i,
    :statuses_count => csv[12].to_i
  }
  next if user[:location] == ""
  location = nil
  REG_CONV_MAP.each{|m|
    if user[:location] =~ m[0]
      location = m[1]
      break
    end
  }
  del_flg = false
  unless location
    DEL_CONV_MAP.each{|m|
      if user[:location] =~ m
        del_flg = true
        #user.delete
        break
      end
    }
  end
  next if del_flg
  next unless location
  list = store_map[location] ||= []
  list << user
  if counter % 10000 == 0
    to_pstore(dump_path , store_map)
    store_map.clear
  end
}
to_pstore(dump_path , store_map)
puts "E"
puts (Time.now - st_time).to_s + "[s]"
rescue => e
  puts e
  puts counter
end
st = Time.now
rank_list = []
Dir.entries(dump_path).each {|e|
  next if e == "." || e == ".."
  PStore.new("#{dump_path}/#{e}").transaction(true){|store|
    rank_list << [e.sub(".store","") , store[:root].length]
  }
}
puts "create rank list " + (Time.now - st_time).to_s + "[s]"
st = Time.now
PStore.new("#{dump_path}/total_rank.store").transaction{|rank|
  rank[:rank] = rank_list.sort{|a,b| b[1] <=> a[1]}
}
puts "create location >>>> " + (Time.now - st).to_s + " [s]"
