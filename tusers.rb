require 'rubygems'
require 'twitter'
require 'sequel'

DB = Sequel.sqlite('tusers.db')

unless DB.table_exists? :users
  DB.create_table :users do
      primary_key :id
      text :screen_name, :unique => true
      text :name
      text :description
      integer :utc_offset
      text :time_zone
      text :location
      integer :followers_count
      integer :friends_count
      integer :statuses_count
  end
  DB.add_index :users, :screen_name
end

class Users < Sequel::Model ; end

id = ARGV[0]
ps = ARGV[1]

t = Twitter::Base.new(Twitter::HTTPAuth.new(id , ps))

t.followers('tottoripy').each{|f|
  # 簡単に API 使用制限数超えちゃうから存在チェック
  # screen_name を uniq 指定してるから二重登録は無い
  if Users.find(:screen_name => f.screen_name)
    next
  end
  u = t.user(f.screen_name)
  Users.create( 
    :screen_name => u.screen_name,
    :name => u.name,
    :description => u.description,
    :screen_name => u.screen_name,
    :utc_offset => u.utc_offset,
    :time_zone => u.time_zone,
    :location => u.location,
    :followers_count => u.followers_count,
    :friends_count => u.friends_count,
    :statuses_count => u.statuses_count
  )
  puts u.screen_name
  puts u.name
  puts u.description
  puts u.screen_name
  puts u.utc_offset
  puts u.time_zone
  puts u.location
  puts u.followers_count
  puts u.friends_count
  puts u.statuses_count

  
  puts "---------------------------------------"
}
