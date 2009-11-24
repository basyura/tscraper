#!/usr/local/bin/ruby



#$LOAD_PATH.push '/home/basyura/local/lib'
#$LOAD_PATH.push '/home/basyura/lib/ruby'
$LOAD_PATH.push '/home/basyura/lib'
ENV['GEM_HOME'] = '/home/basyura/lib/ruby/gem'

#$LOAD_PATH.push "#{$HOME}/local/lib"
#$LOAD_PATH.push "#{$HOME}/lib/ruby"
#$LOAD_PATH.push "#{$HOME}/lib"
#ENV['GEM_HOME'] = "#{$HOME}/lib/ruby/gem"

require 'rubygems'


load 'start.rb'



set :run, false


Rack::Handler::CGI.run Sinatra::Application

