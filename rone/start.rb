require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'sequel'

set :run, true

DB = Sequel.sqlite("../tusers.db")
class Users < Sequel::Model ; end
class Divides < Sequel::Model ; end
class Totals  < Sequel::Model ; end

get '/?' do
  erb :index
end

get '/location/:location' do
  erb :location
end
