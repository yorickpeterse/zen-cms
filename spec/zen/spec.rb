require File.expand_path('../../../lib/zen', __FILE__)
require 'rspec'
require 'webrat'
require 'thor'

# Load all tasks
require __DIR__('../../lib/zen/task/db')

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

# Start Zen
Zen.init

# Require all packages
require __DIR__('../../lib/zen/package/all')

# Migrate the database
db = Zen::Task::DB.new
db.migrate(false)

# Create a default user and group
group = Users::Models::UserGroup.new(
  :name => 'Administrators',
  :slug => 'administrators', :super_group => true
).save

user = Users::Models::User.new(
  :email    => 'spec@domain.tld', :name   => 'Spec',
  :password => 'spec'           , :status => 'open'
).save

user.user_group_pks = [group.id]
