#!/usr/bin/env rackup
#
# Usage:
# * thin start -R config.ru
# * unicorn config.ru
# 
# Note that settings such as the adapter and port are usually ignored as their set
# by the webserver itself, commonly using the -p flag.
# 
require ::File.expand_path('../app', __FILE__)

Ramaze.start(
  :root    => Ramaze.options.roots,
  :started => true,
  :port    => Ramaze::Adapter.options.port
)

run Ramaze