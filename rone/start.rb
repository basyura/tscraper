require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'sequel'

set :run, true

DB = Sequel.sqlite("../tusers.db")
class Users < Sequel::Model ; end
class Divides < Sequel::Model
  def self.users(location)
    Divides.filter(:location => location).inject([]){|list , d|
      list.push Users.find(:screen_name => d.screen_name)   
    }
  end
end
class Totals  < Sequel::Model 
  def self.top100
    limit(100).order(:id)
  end
end

get '/?' do
  erb :index
end

get '/location/:location' do
  erb :location
end
