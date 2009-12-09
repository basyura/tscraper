require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'yaml'
set :run, true

RConfig = YAML.load(open("config.yaml").read)

require 'utils/cache.rb'

def require_db
  require 'sequel'
  Sequel.sqlite(RConfig["db"])
  require 'models/user.rb'
  require 'models/nuser.rb'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/?' do
  cache = Cache.get("index.cache")
  unless cache
    require_db
    @ranking = User.cached_ranking
    @count   = User.cached_count
    cache = erb :index
    Cache.put("index.cache",cache)
  end
  cache
end

get '/location/:location' do
  require_db
  params[:page] ||= 1
  @users = User.find_by_location(params[:location],params[:page])
  erb :location
end

get '/newuser' do
  require_db
  @limit  = 5
  today  = Time.now.strftime("%Y%m%d")
  @nusers = NUser.users(today , @limit , params[:page].to_i * @limit)
  erb :newuser
end

get '/rsslist' do
  erb :rsslist
end
