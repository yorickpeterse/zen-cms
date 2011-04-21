#!/usr/bin/env ruby
#
# File that can be used to start the application as following:
#
#     $ ramaze start
#     $ ruby start.rb
#     $ ./start.rb
# 
require File.expand_path('../app', __FILE__)

Ramaze.start(
  :root    => Ramaze.options.roots,
  :started => true,
  :adapter => Ramaze::Adapter.options.handler,
  :port    => Ramaze::Adapter.options.port
)
