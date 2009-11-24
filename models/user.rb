#
require 'models/perfecture'
#
#
class User < Sequel::Model
  # twitter gem のユーザ情報を使用して新規作成
  def self.create_by_tuser(u)
    create(
      :uid               => u.id,
      :screen_name       => u.screen_name,
      :name              => u.name,
      :description       => u.description ? u.description : "",
      :profile_image_url => u.profile_image_url,
      :url               => u.url ? u.url : "",
      :utc_offset        => u.utc_offset,
      :time_zone         => u.time_zone ? u.time_zone : "",
      :location          => u.location ? u.location : "",
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
        :description       => u.description ? u.description : "" ,
        :profile_image_url => u.profile_image_url,
        :url               => u.url ? u.url : "" ,
        :utc_offset        => u.utc_offset,
        :time_zone         => u.time_zone ? u.time_zone : "",
        :location          => u.location ? u.location : "",
        :location_conv     => CONVERTER.convert(u.location),
        :followers_count   => u.followers_count,
        :friends_count     => u.friends_count,
        :statuses_count    => u.statuses_count
      )
  end
  def self.cached_count
    co = Cache.get("user_count")
    unless co
      co = count
      Cache.put("user_count" , co)
    end
    co
  end
  def self.cached_ranking
    list = Cache.get("ranking")
    unless list
      list = []
      Tusers::PERFECTURE.each_pair{|key , value|
        list << [key , value , filter(:location_conv => key).count]
      }
      list.sort!{|a,b| b[2] <=> a[2]}
      Cache.put("ranking" , list)
    end
    list
  end
  def self.find_by_location(location , page=1)
    page = page ? page.to_i - 1 : 0
    num = 100
    filter(:location_conv => location).order(:id.desc).limit(num,num*page)
  end
  def to_s
    buf = ""
    buf << screen_name
    buf << "\n"
    buf << uid.to_s
    buf << "\n"
    buf << name
    buf << "\n"
    buf << description
    buf << "\n"
    buf << profile_image_url
    buf << "\n"
    buf << url
    buf << "\n"
    buf << screen_name
    buf << "\n"
    buf << utc_offset.to_s
    buf << "\n"
    buf << time_zone
    buf << "\n"
    buf << location
    buf << "\n"
    buf << location_conv
    buf << "\n"
    buf << followers_count.to_s
    buf << "\n"
    buf << friends_count.to_s
    buf << "\n"
    buf << statuses_count.to_s
    buf
  end
end
