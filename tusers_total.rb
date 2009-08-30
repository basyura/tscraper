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


CONV_MAP = {
=begin
  "japan" => "日本",
  "tokyo" => "東京" ,
  "tokyo, japan" => "東京",
  "東京都" => "東京",
  "tokyo,japan" => "東京",
  "tokyo japan" => "東京",
  "tokyo/japan" => "東京",
  "tokyo, jp" => "東京",
  "とーきょー" => "東京",
  "渋谷" => "東京",
  "東京都渋谷区" => "東京",
  "東京都世田谷区" => "東京",
  "東京都港区" => "東京",
  "東京都新宿区" => "東京",
  "東京都文京区" => "東京",
  "東京都大田区" => "東京",
  "東京都江東区" => "東京",
  "東京都千代田区" => "東京",
  "東京都練馬区" => "東京",
  "東京都葛飾区" => "東京",
  "京都市左京区" => "東京",
  "東京都杉並区" => "東京",
  "東京都台東区" => "東京",
  "東京都品川区" => "東京",
  "東京都目黒区" => "東京",
  "東京都豊島区" => "東京",
  "nerima, tokyo" => "東京",
  "japan tokyo" => "東京",
  "tsukuba, ibaraki, japan" => "茨城",
  "tsukuba, japan" => "茨城",
  "tsukuba" => "茨城",
  "つくば" => "茨城",
  "つくば市" => "茨城",
  "筑波" => "茨城",
  "茨城県つくば市" => "茨城",
  "osaka, japan" => "大阪",
  "osaka,japan" => "大阪",
  "osaka" => "大阪",
  "大阪市" => "大阪",
  "大阪府" => "大阪",
  "大阪府大阪市" => "大阪",
  "神奈川県" => "神奈川",
  "kanagawa, japan" => "神奈川",
  "kanagawa,japan" => "神奈川",
  "yokohama" => "神奈川",
  "yokohama, japan" => "神奈川",
  "神奈川県横浜市" => "神奈川",
  "神奈川県川崎市" => "神奈川",
  "神奈川県相模原市" => "神奈川",
  "横浜" => "神奈川",
  "横浜市" => "神奈川",
  "kyoto" => "京都",
  "kyoto, japan" => "京都",
  "kyoto,japan" => "京都",
  "saitama, japan" => "埼玉",
  "japan,saitama" => "埼玉",
  "saitama" => "埼玉",
  "saitama,japan" => "埼玉",
  "埼玉県" => "埼玉",
  "さいたま" => "埼玉",
  "埼玉県さいたま市" => "埼玉",
  "fukuoka, japan" => "福岡",
  "fukuoka" => "福岡",
  "fukuoka,japan" => "福岡",
  "福岡県" => "福岡",
  "sapporo, japan" => "北海道",
  "札幌" => "北海道",
  "Hokkaido, Japan" => "北海道",
  "北海道札幌市" => "北海道",
  "愛知県" => "愛知",
  "名古屋" => "愛知",
  "nagoya" => "愛知",
  "nagoya, japan" => "愛知",
  "aichi" => "愛知",
  "ちば" => "千葉",
  "chiba,japan" => "千葉",
  "千葉県" => "千葉",
  "chiba, japan" => "千葉",
  "okinawa, japan" => "沖縄",
  "hokkaido, japan" => "北海道",
  "hiroshima" => "広島",
  "sendai, japan" => "宮城",
  "宮城県" => "宮城",
  "sendai" => "宮城",
  "神戸" => "兵庫",
  "hyogo,japan" => "兵庫",
  "kobe, japan" => "兵庫",
  "kobe,japan" => "兵庫",
  "静岡県" => "静岡",
  "島根県松江市" => "島根",
  "nagano,japan" => "長野",
  "sapporo" => "札幌",
=end
}
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
  [/jpn/i , "日本"],
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
  [/kawasaki/i , "東京"],
  [/おーさか/ , "大阪"],
  [/オーサカ/ , "大阪"],
  [/チバ/ , "千葉"],
  [/ちば/ , "千葉"],
  [/にっぽん/ , "日本"],
  [/ジャパーン/ , "日本"],
  [/にほん/ , "日本"],
  [/nippon/i , "日本"],
  [/にいがた/ , "新潟"],
  [/よこはま/ , "神奈川"],
  [/横須賀/ , "神奈川"],
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
  [/kagawa/i , "香川"],
  [/ehime/i , "愛媛"],
  [/とっとーり/ , "鳥取"],
  [/ぎふ/ , "岐阜"],
  [/ぐんま/ , "群馬"],
  [/フクオカ/ , "福岡"],
  [/藤沢市/ , "神奈川"],
  [/恵比寿/ , "東京"],
  [/彩の国/ , "埼玉"],
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
    location = CONV_MAP[u.location.to_s.downcase]
    unless location
      REG_CONV_MAP.each{|m|
        if u.location =~ m[0]
          location = m[1]
          break
        end
      }
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
