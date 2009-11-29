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
    cache = erb :index
    Cache.put("index.cache",cache)
  end
  cache
end

get '/location/:location' do
  require_db
  params[:page] ||= 1
  erb :location
end

get '/newuser' do
  require_db
  erb :newuser
end
