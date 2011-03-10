require File.expand_path('../../../lib/zen', __FILE__)
require 'rspec'
require 'webrat'

# Configure the database
Zen::Database.mode :dev do |db|
  db.adapter  = 'sqlite'
  db.database = ':memory:'
end

# Update all paths
Ramaze.options.roots = [__DIR__]
Ramaze.options.mode  = :dev
Zen.options.root     = __DIR__

Zen::Language.options.paths.push(__DIR__('resources'))

Zen.init

# Migrate the database

