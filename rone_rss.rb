require 'rss'
class RSSGenerator
  def self.generate(users)
    rss_path = RConfig["rss_dir"] + "/index.rdf"
    if File.exist?(rss_path)
      old_rss = RSS::Parser.parse(open(rss_path).read)
    end
    rss = RSS::Maker.make("2.0") do |maker|
      maker.channel.about = "http://basyura.org/rone/rss/index.rdf"
      maker.channel.title = "ROneUsers"
      maker.channel.description = "Twitter ユーザを県別に集計"
      maker.channel.link = "http://basyura.org/rone"
      maker.items.do_sort = true

      if old_rss
        old_rss.items.each{|old_item|
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

    open(rss_path ,"w"){|f| f.puts rss}
  end
end
