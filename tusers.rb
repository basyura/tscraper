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
require 'utils/location_converter'

id         = ARGV[0]
ps         = ARGV[1]
dbpath     = ARGV[2]
cache_path = ARGV[3]
skip_user  = ARGV[4]

JPN_TIME_ZONE = ['Osaka' , 'Sapporo' , 'Tokyo']
CONVERTER = LocationConverter.new(cache_path)
DB = Sequel.sqlite(dbpath)
#DB = Sequel.connect('mysql://root:bz@127.0.0.1/tusers')
require 'models/user'
require 'models/nuser'
require 'models/crawl_status'


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
    user = User.create_by_tuser(u)
    puts user.screen_name
    puts user
    # 新着ユーザ登録 ロケーションの変換ができた場合だけ
    if user.location_conv != ""
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
    next_user = User.find(:id => 1)
  end
  if JPN_TIME_ZONE.member? next_user.time_zone 
    puts "next user : #{uid} → #{next_user.uid}"
    return next_user
  else
    CrawlStatus.find(:status => 'crawl').save_next_user(next_user.uid)
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
