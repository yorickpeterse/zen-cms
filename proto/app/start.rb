#!/usr/bin/env ruby
#
# File that can be used to start the application as following:
#
#     $ ramaze start
#     $ ruby start.rb
#     $ ./start.rb
# 
require File.expand_path('../app', __FILE__)

Ramaze.start(:adapter => :webrick, :port => 7000, :file => __FILE__)
