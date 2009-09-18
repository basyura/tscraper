require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'pstore'
require 'sequel'

set :run, true

DB = Sequel.sqlite("../tusers.db")
class Users < Sequel::Model ; end
=begin
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

=end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def top100
    rank = nil
    PStore.new("../data/total_rank.store").transaction(true) {|store|
      rank = store[:rank]
    }
    rank
  end
  def users(location , page=1)
    page = page ? page.to_i - 1 : 0
    num = 100
    users = []
    PStore.new("../data/#{location}.store").transaction(true) {|store|
      users = store[:root]
    }
    list = []
    len = (page * num + num)
    len = users.length if len > users.length
    for i in (page * num)...len
      list << users[i]
    end
    puts list[0]
    list
  end
end


get '/?' do
  erb :index
end

get '/location/:location' do
  params[:page] ||= 1
  erb :location
end
