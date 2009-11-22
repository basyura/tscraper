#
#
#
class User < Sequel::Model
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
end
