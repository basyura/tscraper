require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'pstore'
require 'sequel'
require 'yaml'

set :run, true

Config = YAML.load(open("config.yaml").read)
DB = Sequel.sqlite(Config["db"])

require 'utils/cache.rb'
require 'models/user.rb'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/?' do
  erb :index
end

get '/location/:location' do
  params[:page] ||= 1
  erb :location
end
