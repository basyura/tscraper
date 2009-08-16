require 'rubygems'
require 'mechanize'

class TScraper
  def initialize(user_name , password)
    @agent = WWW::Mechanize.new
    @agent.max_history = 1
    page = @agent.get('http://twitter.com')
    form = page.forms[0]
    form["session[username_or_email]"] = user_name
    form["session[password]"] = password
    page = @agent.submit(form)
    unless page.root.xpath('.//body').attr("id") == "home"
      raise StandardError.new "ログインできません"
    end
  end
  def user(screen_name)
    url = "http://twitter.com/#{screen_name}"
    div = @agent.get(url).root.xpath(".//div[@id='side']")
    map = {
      :name    => div.xpath(".//span[@class='fn']").inner_text ,
      :address => div.xpath(".//span[@class='adr']").inner_text ,
      :url     => div.xpath(".//a[@class='url']").attr("href") ,
      :bio     => div.xpath(".//span[@class='bio']").inner_text ,
      :following_count => div.xpath(".//span[@id='following_count']").inner_text ,
      :follower_count  => div.xpath(".//span[@id='follower_count']").inner_text
    }
  end
end

id = ARGV[0]
ps = ARGV[1]

t = TScraper.new(id , ps)
t.user("onose_meguro").each_pair{|key,value|
  puts key.to_s + " " + value
}
