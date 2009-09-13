#!ruby
#
# TODO
#   ・一定量を crawl したらステータスに変化が無いかをチェックする
#
#
require 'rubygems'
require 'twitter'
require 'mysql'
require 'sequel'


JPN_TIME_ZONE = ['Osaka' , 'Sapporo' , 'Tokyo']


id = ARGV[0]
ps = ARGV[1]
dbpath = ARGV[2]
skip_user = ARGV[3]


DB = Sequel.sqlite(dbpath)
#DB = Sequel.connect('mysql://root:bz@127.0.0.1/tusers')

unless DB.table_exists? :users
  DB.create_table :users do
      primary_key :id
      String :screen_name
      String :uid ,:unique => true
      String :name
      varchar :description , :length => 500
      varchar :profile_image_url , :length => 500
      varchar :url , :length => 500
      integer :utc_offset
      String :time_zone
      String :location
      integer :followers_count
      integer :friends_count
      integer :statuses_count
  end
  DB.add_index :users, :screen_name
  DB.add_index :users, :uid
end
unless DB.table_exists? :crawl_statuses
  DB.create_table :crawl_statuses do
      primary_key :id
      String :status, :unique => true
      integer :uid
      integer :page
      integer :count
  end
  DB.add_index :crawl_statuses, :status
end

class Users < Sequel::Model ; end
class CrawlStatuses < Sequel::Model
  set_dataset :crawl_statuses
  def save_next_user(next_uid)
      self.uid   = next_uid
      self.page  = 1
      self.count = 0
      self.save
  end
  def save_next_page
    self.page += 1
    self.count = 0
    self.save
  end
  def save_next_count
    self.count += 1
    self.save
  end
end

def regist(twitter , followers)
  followers.each{|u|
    # 簡単に API 使用制限数超えちゃうから存在チェック
    # screen_name を uniq 指定してるから二重登録は無い
    user = Users.find(:uid => u.id)
    if user
      print "#{u.screen_name} (#{u.id}) is already exist."
      user.update(
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
      puts " ... update record."
      next
    end
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
def find_next_user(uid)
  user = Users.find(:uid => uid)
  if user
    user_id = user.id
    while true
      next_user = Users.find(:id => (user_id += 1))
      if next_user
        break
      end
    end 
  else
    next_user = Users.find(:id => 1)
  end
  if JPN_TIME_ZONE.member? next_user.time_zone 
    puts "next user : #{uid} → #{next_user.uid}"
    return next_user
  else
    return find_next_user(next_user.uid)
  end
end

def crawl_users(id , ps)
  twitter = Twitter::Base.new(Twitter::HTTPAuth.new(id , ps))
  while true
    # crawl satus を取得
    crawl = CrawlStatuses.find(:status => 'crawl')
    puts "■■■ crawl #{crawl.uid} page => #{crawl.page}" 
    # API 経由で followers を取得
    followers = twitter.friends(:id => crawl.uid ,  :page => crawl.page)
    # DB にユーザ情報を保存
    regist(twitter , followers)
    # 100 以下の場合は次のページ情報が無いはず
    if followers.length < 100
      # 次のユーザを取得
      next_user = find_next_user(crawl.uid)
      # ユーザを変更して crawl status を更新
      crawl.save_next_user(next_user.uid)
      next
    end
    # ページを変更して crawl status を更新
    crawl.save_next_page
  end
end


# ここから main


unless CrawlStatuses.find(:status => 'crawl')
  CrawlStatuses.create(
    :status => 'crawl',
    :uid => 15797125,
    :page => 1,
    :count => 0
  )
end

if skip_user
  crawl = CrawlStatuses.find(:status => 'crawl')
  next_user = find_next_user(crawl.uid)
  crawl.uid = next_user.uid
  crawl.page = 1
  crawl.count = 0
  crawl.save
end

retry_count = 5

for i in 0...retry_count
  begin 
    crawl_users(id , ps)
  rescue Twitter::RateLimitExceeded
    puts "over limit."
    exit
  rescue => e
    puts e
    crawl = CrawlStatuses.find(:status => 'crawl')
    if crawl.count >= 2
      crawl.save_next_page
    else
      crawl.save_next_count
    end
    puts "sleep a few seconds ..... for retry #{i + 1}"
    sleep 5
  end
end

#load 'tusers_total.rb' 
