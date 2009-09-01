#!ruby

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite(ARGV[0])
class Users < Sequel::Model ; end

unless DB.table_exists? :divides
  DB.create_table :divides do
      primary_key :id
      text :screen_name, :unique => true
      text :location
  end
  DB.add_index :divides, :location
end
unless DB.table_exists? :totals
  DB.create_table :totals do
      primary_key :id
      text :location , :unique => true
      integer :count
  end
end
class Divides < Sequel::Model ; end
class Totals  < Sequel::Model ; end


REG_CONV_MAP = [
  [/北海道/,"北海道"],
  [/青森/,"青森"],
  [/岩県/,"岩県"],
  [/宮城/,"宮城"],
  [/秋田/,"秋田"],
  [/山形/,"山形"],
  [/福島/,"福島"],
  [/茨城/,"茨城"],
  [/栃木/,"栃木"],
  [/群馬/,"群馬"],
  [/埼玉/,"埼玉"],
  [/千葉/,"千葉"],
  [/東京/,"東京"],
  [/神奈川/,"神奈川"],
  [/新潟/,"新潟"],
  [/富山/,"富山"],
  [/石川/,"石川"],
  [/福井/,"福井"],
  [/山梨/,"山梨"],
  [/長野/,"長野"],
  [/岐阜/,"岐阜"],
  [/静岡/,"静岡"],
  [/愛知/,"愛知"],
  [/三重/,"三重"],
  [/滋賀/,"滋賀"],
  [/京都/,"京都"],
  [/大阪/,"大阪"],
  [/兵庫/,"兵庫"],
  [/奈良/,"奈良"],
  [/和歌山/,"和歌山"],
  [/鳥取/,"鳥取"],
  [/島根/,"島根"],
  [/岡山/,"岡山"],
  [/広島/,"広島"],
  [/山口/,"山口"],
  [/徳島/,"徳島"],
  [/香川/,"香川"],
  [/愛媛/,"愛媛"],
  [/高知/,"高知"],
  [/福岡/,"福岡"],
  [/佐賀/,"佐賀"],
  [/長崎/,"長崎"],
  [/熊本/,"熊本"],
  [/大分/,"大分"],
  [/宮崎/,"宮崎"],
  [/鹿児島/,"鹿児島"],
  [/沖縄/,"沖縄"],
  [/yokohama/i , "神奈川"],
  [/tokyo/i , "東京"],
  [/saitama/i , "埼玉"],
  [/osaka/i , "大阪"],
  [/tsukuba/i , "茨城"],
  [/sapporo/i , "北海道"],
  [/hokkaido/i , "北海道"],
  [/kanagawa/i , "神奈川"],
  [/さいたま/ , "埼玉"],
  [/okayama/i , "岡山"],
  [/yamaguchi/i , "山口"],
  [/fukuoka/i , "福岡"],
  [/kyoto/i , "京都"],
  [/okinawa/i , "沖縄"],
  [/chiba/i , "千葉"],
  [/nagoya/i , "愛知"],
  [/hyogo/i , "兵庫"],
  [/kobe/i , "兵庫"],
  [/nara/i , "奈良"],
  [/nagano/i , "長野"],
  [/aichi/i , "愛知"],
  [/神戸/ , "兵庫"],
  [/saga/i , "佐賀"],
  [/fukui/i , "福井"],
  [/naha/i , "沖縄"],
  [/hiroshima/i , "広島"],
  [/shizuoka/i , "静岡"],
  [/tottori/i , "鳥取"],
  [/shibuya/i , "東京"],
  [/iwate/i , "岩手"],
  [/岩手/i , "岩手"],
  [/toyama/i , "富山"],
  [/kumamoto/i , "熊本"],
  [/yamagata/i , "山形"],
  [/tochigi/i , "栃木"],
  [/hakodate/i , "北海道"],
  [/tokushima/i , "徳島"],
  [/横浜/i , "神奈川"],
  [/ヨコハマ/i , "神奈川"],
  [/練馬/i , "東京"],
  [/しまね/i , "島根"],
  [/なごや/i , "愛知"],
  [/japan/i , "日本"],
  [/^jpn$/i , "日本"],
  [/^jp$/i , "日本"],
  [/sendai/i , "宮城"],
  [/名古屋/ , "愛知"],
  [/つくば/ , "茨城"],
  [/仙台/ , "宮城"],
  [/しぶや/ , "東京"],
  [/港区/ , "東京"],
  [/蒲田/ , "東京"],
  [/新宿/ , "東京"],
  [/品川/ , "東京"],
  [/川崎/ , "東京"],
  [/原宿/ , "東京"],
  [/とうきょう/ , "東京"],
  [/とーきょー/ , "東京"],
  [/トーキョー/ , "東京"],
  [/とうきょー/ , "東京"],
  [/トウキョウ/ , "東京"],
  [/TOKIO/i , "東京"],
  [/大田区/ , "東京"],
  [/秋葉原/ , "東京"],
  [/板橋/ , "東京"],
  [/渋谷/ , "東京"],
  [/荒川区/ , "東京"],
  [/五反田/ , "東京"],
  [/江東区/ , "東京"],
  [/目黒区/ , "東京"],
  [/銀座/ , "東京"],
  [/池袋/ , "東京"],
  [/世田谷/ , "東京"],
  [/文京区/ , "東京"],
  [/武蔵野/ , "東京"],
  [/杉並区/ , "東京"],
  [/千代田区/ , "東京"],
  [/中央区/ , "東京"],
  [/中野区/ , "東京"],
  [/^中野$/ , "東京"],
  [/高円寺/ , "東京"],
  [/kawasaki/i , "東京"],
  [/八王子/i , "東京"],
  [/浅草/i , "東京"],
  [/麻布十番/i , "東京"],
  [/下北沢/i , "東京"],
  [/おーさか/ , "大阪"],
  [/おおさか/ , "大阪"],
  [/オーサカ/ , "大阪"],
  [/チバ/ , "千葉"],
  [/ちば/ , "千葉"],
  [/にっぽん/ , "日本"],
  [/ジャパーン/ , "日本"],
  [/にほん/ , "日本"],
  [/nippon/i , "日本"],
  [/にいがた/ , "新潟"],
  [/Niigata/i , "新潟"],
  [/よこはま/ , "神奈川"],
  [/横須賀/ , "神奈川"],
  [/かながわ/ , "神奈川"],
  [/鎌倉/ , "神奈川"],
  [/湘南/ , "神奈川"],
  [/金沢/ , "石川"],
  [/miyagi/i , "宮城"],
  [/ibaraki/i , "茨城"],
  [/いばらき/ , "茨城"],
  [/筑波/ , "茨城"],
  [/ひろしま/ , "広島"],
  [/kawagoe/i , "埼玉"],
  [/miyazaki/i , "宮崎"],
  [/kagoshima/i , "鹿児島"],
  [/さいたーまー/ , "埼玉"],
  [/ひょーご/ , "兵庫"],
  [/札幌/ , "北海道"],
  [/さっぽろ/ , "北海道"],
  [/kagawa/i , "香川"],
  [/ehime/i , "愛媛"],
  [/とっとーり/ , "鳥取"],
  [/ぎふ/ , "岐阜"],
  [/ぐんま/ , "群馬"],
  [/フクオカ/ , "福岡"],
  [/ふくおか/ , "福岡"],
  [/藤沢市/ , "神奈川"],
  [/恵比寿/ , "東京"],
  [/吉祥寺/ , "東京"],
  [/彩の国/ , "埼玉"],
  [/都内/ , "東京"],
  [/^earth$/i , "地球"],
  [/Ｊａｐａｎ/ , "日本"],
  [/琵琶湖/ , "滋賀"],
  [/きょうと/ , "京都"],
]
DEL_CONV_MAP = [
  /Los Angeles/ ,
  /^usa$/i ,
  /Los Angeles/i ,
  /California/i ,
  /New York/i ,
  /United States/i ,
  /Los Angeles/ ,
  /^US$/i ,
  /New York/,
  /San Francisco/i ,
  /Florida/i ,
  /^NY$/ ,
  /San Diego/i ,
  /Chicago/,
  /^NYC$/i ,
  /Australia/i ,
  /Seattle/i ,
  /Chicago/i ,
  /Texas/i ,
  /New Jersey/i ,
  /Atlanta/i ,
  /Colorado/i ,
  /Sydney/i ,
  /Melbourne/i ,
  /Las Vegas/i ,
  /Washington/i ,
  /Shanghai/i ,
  /Hong Kong/i ,
  /China/i ,
  /Tehran/i ,
  /United Kingdom/i ,
  /UK/i ,
  /London/i ,
  /Canada/i ,
  /England/i ,
  /Vancouver/i ,
  /Taiwan/i ,
  /India/i ,
  /Indonesia/i ,
  /Berlin/i ,
  /Tehran/i ,
  /New Zealand/i ,
  /Africa/i ,
  /Nashville/i ,
  /Israel/i ,
  /Costa Rica/i ,
  /indonesia/i ,
  /France/i ,
  /Dallas/i ,
  /Philadelphia/i ,
  /Idaho/i ,
  /Philippines/i ,
  /Brasil/i ,
  /Austin/i ,
  /Toronto/i ,
  /Charlotte/i ,
  /Europe/i ,
  /Germany/i ,
  /Singapore/i ,
  /Everywhere/i ,
  /Worldwide/i ,
  /Malaysia/i ,
  /Global/i ,
  /International/i ,
  /Brazil/i ,
  /Asia/i ,
  /^Utah$/i ,
  /Michigan/i ,
  /^CA$/ ,
  /Boston/i ,
  /Taipei/i ,
  /Sweden/i ,
  /Boston/i ,
  /Arizona/i , 
  /St. Louis/i ,
  /Silicon Valley/i ,
  /Bangkok/i ,
  /Internet/i ,
  /somewhere/i ,
  /Switzerland/i ,
  /Korea/i ,
  /Paris/i ,
  /Minneapolis/i ,
  /Amsterdam/i ,
  /Phoenix/i ,
  /Beijing/i ,
  /U.S.A./i ,
  /San Jose/i ,
  /Online/i ,
  /Italy/i ,
  /Brooklyn/i ,
  /Wisconsin/i ,
  /Hawaii/i ,
  /World/i ,
  /Oakland/i ,
  /Poland/i ,
  /香港/ ,
  /U.S./ ,
  /アメリカ/ ,
  /Scotland/ ,
  /Twitter/ ,
  /Denver/ ,
  /Portland/ ,
]

map = {}

# トランザクション
DB.transaction do
  Divides.delete
  Totals.delete
  Users.find_all{|u|
    puts u.screen_name .to_s + " → " + u.location.to_s
    if u.location.to_s.strip == ""
      u.location = "未設定"
    end
    location = nil
    unless location
      REG_CONV_MAP.each{|m|
        if u.location =~ m[0]
          location = m[1]
          break
        end
      }
      del_flg = false
      unless location
        DEL_CONV_MAP.each{|m|
          if u.location =~ m
            puts "★★★ delete ... #{u.screen_name}"
            del_flg = true
            u.delete
            break
          end
        }
      end
      next if del_flg
    end
    if location
      u.location = location
    end
    Divides.create( 
      :screen_name => u.screen_name,
      :location => u.location
    )

    map[u.location] ||= 0
    map[u.location] += 1
  }
  #f = open("tusers_out.txt","w")
  map.to_a.sort{|a,b|
    b[1] <=> a[1]
  }.each{|v|
    next if v[0] == "未設定"
    puts v[0].to_s + " → " + v[1].to_s
    #f.puts v[0].to_s + " → " + v[1].to_s
    Totals.create(
      :location => v[0],
      :count => v[1]
    )
  }
end
