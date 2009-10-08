#!ruby

require 'rubygems'
require 'sequel'
require 'tusers_perfecture'

DB = Sequel.sqlite(ARGV[0])
class Users < Sequel::Model ; end
Tusers::PERFECTURE.each_pair{|key , value|
  st_time = Time.now
  puts "#{Time.now - st_time} " + key.ljust(10) + " " + Users.filter(:location_conv => key).count.to_s
  
}
