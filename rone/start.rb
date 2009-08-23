require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'sequel'

set :run, true

DB = Sequel.sqlite("../tusers.db")
class Users < Sequel::Model ; end
class Divides < Sequel::Model
  def self.users(location , page=1)
    page = page ? page.to_i - 1 : 0
    num = 100
    Divides.filter(:location => location).order(:id.desc).limit(num,page*num).inject([]){|list , d|
      list.push Users.find(:screen_name => d.screen_name)   
    }
  end
end
class Totals  < Sequel::Model 
  def self.top100
    limit(100).order(:id)
  end
end


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
