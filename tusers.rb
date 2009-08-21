#!ruby
#
# TODO
#   ・一定量を crawl したらステータスに変化が無いかをチェックする
#
#
require 'rubygems'
require 'twitter'
require 'sequel'

JPN_TIME_ZONE = ['Osaka' , 'Sapporo' , 'Tokyo']


id = ARGV[0]
ps = ARGV[1]
db_path = ARGV[2]


DB = Sequel.sqlite(db_path)

unless DB.table_exists? :users
  DB.create_table :users do
      primary_key :id
      text :screen_name, :unique => true
      text :uid
      text :name
      text :description
      text :profile_image_url
      text :url
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
      integer :count
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
      :uid => u.id,
      :screen_name => u.screen_name,
      :name => u.name,
      :description => u.description,
      :profile_image_url => u.profile_image_url,
      :url => u.url,
      :utc_offset => u.utc_offset,
      :time_zone => u.time_zone,
      :location => u.location,
      :followers_count => u.followers_count,
      :friends_count => u.friends_count,
      :statuses_count => u.statuses_count
    )
    puts u.screen_name
    puts u.uid
    puts u.name
    puts u.description
    puts u.profile_image_url
    puts u.url
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
#
# 次に crawl 対象となるユーザを捜す
#
def find_next_user(screen_name)
  user = Users.find(:screen_name => screen_name)
  if user
    next_user = Users.find(:id => (user.id += 1))
  else
    next_user = Users.find(:id => 1)
  end
  if JPN_TIME_ZONE.member? next_user.time_zone 
    return next_user
  else
    return find_next_user(next_user.screen_name)
  end
end

# ここから main


unless CrawlStatuses.find(:status => 'crawl')
  CrawlStatuses.create(
    :status => 'crawl',
    :screen_name => id,
    :page => 1,
    :count => 0
  )
end

twitter = Twitter::Base.new(Twitter::HTTPAuth.new(id , ps))
begin
  while true
    # crawl satus を取得
    crawl = CrawlStatuses.find(:status => 'crawl')
    puts "■■■ crawl #{crawl.screen_name} page => #{crawl.page}" 
    # API 経由で followers を取得
    followers = twitter.followers(:screen_name => crawl.screen_name , :lite => true , :page => crawl.page)
    # DB にユーザ情報を保存
    regist(twitter , followers)
    # 100 以下の場合は次のページ情報が無いはず
    if followers.length < 100
      # 次のユーザを取得
      next_user = find_next_user(crawl.screen_name)
      # ユーザを変更して crawl status を更新
      crawl.screen_name = next_user.screen_name
      crawl.page = 1
      crawl.count = 0
      crawl.save
      next
    end
    # ページを変更して crawl status を更新
    crawl.page += 1
    crawl.count = 0
    crawl.save
  end
rescue
  crawl = CrawlStatuses.find(:status => 'crawl')
  if crawl.count >= 3
    crawl.count = 0
    crawl.page += 1
  else
    crawl.count += 1
  end
  crawl.save
end
