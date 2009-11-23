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
require 'location_converter'

JPN_TIME_ZONE = ['Osaka' , 'Sapporo' , 'Tokyo']

id         = ARGV[0]
ps         = ARGV[1]
dbpath     = ARGV[2]
cache_path = ARGV[3]
skip_user  = ARGV[4]

CONVERTER = LocationConverter.new(cache_path)

DB = Sequel.sqlite(dbpath)
#DB = Sequel.connect('mysql://root:bz@127.0.0.1/tusers')

unless DB.table_exists? :users
  DB.create_table :users do
      primary_key :id
      String  :screen_name
      String  :uid ,:unique => true
      String  :name
      varchar :description , :length => 500
      varchar :profile_image_url , :length => 500
      varchar :url , :length => 500
      integer :utc_offset
      String  :time_zone
      String  :location
      String  :location_conv
      integer :followers_count
      integer :friends_count
      integer :statuses_count
  end
  DB.add_index :users, :screen_name
  DB.add_index :users, :uid
  DB.add_index :users, :location_conv
end
unless DB.table_exists? :crawl_statuses
  DB.create_table :crawl_statuses do
      primary_key :id
      String  :status, :unique => true
      integer :uid
      integer :page
      integer :count
  end
  DB.add_index :crawl_statuses, :status
end
unless DB.table_exists? :new_users
  DB.create_table :new_users do
      primary_key :id
      String :uid  ,:unique => true
      String :date
  end
  DB.add_index :new_users, :date
end

class User < Sequel::Model
  # twitter gem のユーザ情報を使用して新規作成
  def self.create_by_tuser(u)
    create(
      :uid               => u.id,
      :screen_name       => u.screen_name,
      :name              => u.name,
      :description       => u.description,
      :profile_image_url => u.profile_image_url,
      :url               => u.url,
      :utc_offset        => u.utc_offset,
      :time_zone         => u.time_zone,
      :location          => u.location,
      :location_conv     => CONVERTER.convert(u.location),
      :followers_count   => u.followers_count,
      :friends_count     => u.friends_count,
      :statuses_count    => u.statuses_count
    )
  end
  def update_by_tuser(u)
      update(
        :screen_name       => u.screen_name,
        :name              => u.name,
        :description       => u.description,
        :profile_image_url => u.profile_image_url,
        :url               => u.url,
        :utc_offset        => u.utc_offset,
        :time_zone         => u.time_zone,
        :location          => u.location,
        :location_conv     => CONVERTER.convert(u.location),
        :followers_count   => u.followers_count,
        :friends_count     => u.friends_count,
        :statuses_count    => u.statuses_count
      )
  end
  def to_s
    buf = ""
    buf << screen_name
    buf << "¥n"
    buf << uid
    buf << "¥n"
    buf << name
    buf << "¥n"
    buf << description
    buf << "¥n"
    buf << profile_image_url
    buf << "¥n"
    buf << url
    buf << "¥n"
    buf << screen_name
    buf << "¥n"
    buf << utc_offset
    buf << "¥n"
    buf << time_zone
    buf << "¥n"
    buf << location
    buf << "¥n"
    buf << location_conv
    buf << "¥n"
    buf << followers_count.to_s
    buf << "¥n"
    buf << friends_count.to_s
    buf << "¥n"
    buf << statuses_count.to_s
    buf
  end
end
class NUser < Sequel::Model
  set_dataset :new_users
end
class CrawlStatus < Sequel::Model
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
    user = User.find(:uid => u.id)
    if user
      print "#{u.screen_name} (#{u.id}) is already exist."
      user.update_by_tuser(u)
      puts " ... update record."
      next
    end
    user = createcreate_by_tuser(u)
    puts user.screen_name
    puts user
    # 新着ユーザ登録 ロケーションの変換ができた場合だけ
    if user.location != ""
      NUser.create(
        :uid  => user.uid ,
        :date => Time.now.strftime("%Y%m%d")
      )
    end
    puts "---------------------------------------"
  }
end
#
# 次に crawl 対象となるユーザを捜す
#
def find_next_user(uid)
  user = User.find(:uid => uid)
  if user
    user_id = user.id
    while true
      next_user = User.find(:id => (user_id += 1))
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
    crawl = CrawlStatus.find(:status => 'crawl')
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


unless CrawlStatus.find(:status => 'crawl')
  CrawlStatus.create(
    :status => 'crawl',
    :uid    => 15797125,
    :page   => 1,
    :count  => 0
  )
end

if skip_user
  crawl = CrawlStatus.find(:status => 'crawl')
  next_user = find_next_user(crawl.uid)
  crawl.uid   = next_user.uid
  crawl.page  = 1
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
    crawl = CrawlStatus.find(:status => 'crawl')
    if crawl.count >= 2
      crawl.save_next_page
      user = find_next_user(crawl.uid)
      crawl.save_next_user(user.uid)
    else
      crawl.save_next_count
    end
    puts "sleep a few seconds ..... for retry #{i + 1}"
    sleep 5
  end
end

#load 'tusers_total.rb' 
