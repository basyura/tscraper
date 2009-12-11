require 'rss'
class RSSGenerator
  def self.generate(users)
    umap = users.inject(Hash.new){|map,u| 
      (map[u.location_conv] ||= []) << u
      map
    }
    umap.each_pair{|key,value| generate_location(key,value)}
    generate_location("all",users)
  end

  private
  def self.generate_location(location , users)
    rss_path = RConfig["rss_dir"] + "/#{location}.rdf"
    if File.exist?(rss_path)
      old_rss = RSS::Parser.parse(open(rss_path).read)
    end
    rss = RSS::Maker.make("2.0") do |maker|
      maker.channel.about = "http://basyura.org/rone/rss/#{location}.rdf"
      maker.channel.title = location == "all" ? "ROneUsers" : "ROneUsers - #{PREF_CONV_MAP[location]}"
      maker.channel.description = location == "all" ? "新着 Twitter ユーザ" : "#{PREF_CONV_MAP[location]}の新着 Twitter ユーザ"
      maker.channel.link = "http://basyura.org/rone/"
      maker.items.do_sort = true

      if old_rss
        old_rss.items.each{|old_item|
          # 二日以上前のものは追加しない
          next if Time.now - old_item.date > 24 * 60 * 60 * 2
          item = maker.items.new_item
          item.link  = old_item.link
          item.title = old_item.title
          item.description = old_item.description
          item.date = old_item.date
        }
      end

      users.each{|user|
        item = maker.items.new_item
        item.link  = "http://twitter.com/#{user.screen_name}"
        item.title = user.name
        item.description =<<-EOF
          <img src="#{user.profile_image_url}"><br>
          ##{user.location}<br>
          <a href="#{user.url}">#{user.url}</a><br>
          #{user.description}
        EOF
        item.date = Time.now
      }
      maker.image.title = "ROneUsers"
      maker.image.url = "http://basyura.org/rone/img/logo.png"
    end
    puts "create #{rss_path} -> #{users.length}"
    open(rss_path ,"w"){|f| f.puts rss}
  end
  #TODO converter と共通化
  PREF_CONV_MAP = {
    "hokkaido" => "北海道",
    "aomori" => "青森",
    "iwate" => "岩手県",
    "miyagi" => "宮城",
    "akita" => "秋田",
    "yamagata" => "山形",
    "fukushima" => "福島",
    "ibaraki" => "茨城",
    "totigi" => "栃木",
    "gunma" => "群馬",
    "saitama" => "埼玉",
    "chiba" => "千葉",
    "tokyo" => "東京",
    "kanagawa" => "神奈川",
    "niigata" => "新潟",
    "toyama" => "富山",
    "ishikawa" => "石川",
    "fukui" => "福井",
    "yamanashi" => "山梨",
    "nagano" => "長野",
    "gifu" => "岐阜",
    "sizuoka" => "静岡",
    "aichi" => "愛知",
    "mie" => "三重",
    "shiga" => "滋賀",
    "kyoto" => "京都",
    "osaka" => "大阪",
    "hyogo" => "兵庫",
    "nara" => "奈良",
    "wakayama" => "和歌山",
    "tottori" => "鳥取",
    "shimane" => "島根",
    "okayama" => "岡山",
    "hiroshima" => "広島",
    "yamaguchi" => "山口",
    "tokushima" => "徳島",
    "kagawa" => "香川",
    "ehime" => "愛媛",
    "kochi" => "高知",
    "fukuoka" => "福岡",
    "saga" => "佐賀",
    "nagasaki" => "長崎",
    "kumamoto" => "熊本",
    "oita" => "大分",
    "miyazaki" => "宮崎",
    "kagoshima" => "鹿児島",
    "okinawa" => "沖縄",
    "japan" => "日本",
  }
end
