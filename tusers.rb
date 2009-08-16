require 'rubygems'
require 'twitter'
require 'sequel'

JPN_TIME_ZONE = ['Osaka' , 'Sapporo' , 'Tokyo']

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
unless DB.table_exists? :crawl_statuses
  DB.create_table :crawl_statuses do
      primary_key :id
      text :status, :unique => true
      text :screen_name
      integer :page
  end
  DB.add_index :crawl_statuses, :status
end

class Users < Sequel::Model ; end
class CrawlStatuses < Sequel::Model
  set_dataset :crawl_statuses
end

def regist(twitter , followers)
  followers.each{|f|
    # 簡単に API 使用制限数超えちゃうから存在チェック
    # screen_name を uniq 指定してるから二重登録は無い
    if Users.find(:screen_name => f.screen_name)
      puts "#{f.screen_name} is already exist."
      next
    end
    u = twitter.user(f.screen_name)
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
end
def find_next_user(screen_name)
  user = Users.find(:screen_name => screen_name)
  if user
    next_user = Users.find(:id => (user.id += 1))
  else
    next_user = Users.find(:id => 1)
  end
  if JPN_TIME_ZONE.exist? next_user.time_zone 
    return next_user
  else
    return find_next_user(next_user.screen_name)
  end
end

id = ARGV[0]
ps = ARGV[1]

unless CrawlStatuses.find(:status => 'crawl')
  CrawlStatuses.create(
    :status => 'crawl',
    :screen_name => id,
    :page => 1
  )
end


twitter = Twitter::Base.new(Twitter::HTTPAuth.new(id , ps))
while true
  crawl = CrawlStatuses.find(:status => 'crawl')
  puts "■■■ crawl #{crawl.screen_name} page => #{crawl.page}" 
  followers = twitter.followers(:screen_name => crawl.screen_name , :lite => true , :page => crawl.page)
  regist(twitter , followers)
  if followers.length < 100
    next_user = find_next_user(crawl.screen_name)
    crawl.screen_name = next_user.screen_name
    crawl.page = 1
    crawl.save
    next
  end
  crawl.page += 1
  crawl.save
end
