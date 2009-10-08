require 'rubygems'
gem 'rack' , '0.9.1'
require 'sinatra'
require 'pstore'
require 'sequel'
require 'tusers_perfecture'

set :run, true

DB = Sequel.sqlite("../tusers.db")
class Users < Sequel::Model ; end

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
    Users.filter(:location_conv => location).order(:id).limit(num,num*page)
    #users = []
    #PStore.new("../data/#{location}.store").transaction(true) {|store|
    #  users = store[:root]
    #}
    #list = []
    #len = (page * num + num)
    #len = users.length if len > users.length
    #for i in (page * num)...len
    #  list << users[i]
    #end
    #puts list[0]
    #list
  end
  def ranking
    list = []
    Tusers::PERFECTURE.each_pair{|key , value|
      list << [key , value , Users.filter(:location_conv => key).count]
    }
    list.sort{|a,b| b[2] <=> a[2]}
  end
end


get '/?' do
  erb :index
end

get '/location/:location' do
  params[:page] ||= 1
  erb :location
end
