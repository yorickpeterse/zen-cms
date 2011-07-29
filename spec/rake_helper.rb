require File.expand_path('../../lib/zen', __FILE__)

Ramaze.setup(:verbose => false) do
  gem 'bacon'    , ['~> 1.1.0']
  gem 'sqlite3'  , ['~> 1.3.4']
end

# Update all paths
Ramaze.options.roots = [__DIR__]
Ramaze.options.mode  = :dev
Zen.root             = __DIR__

Zen::Language.options.paths.push(__DIR__('fixtures'))

# Configure the database
Zen.database = Sequel.connect(
  :adapter   => 'sqlite',
  :database  => __DIR__('database.db'),
  :test      => true,
  :encoding  => 'utf8'
)

# Start Zen
Zen.init

# Require all packages
require __DIR__('../lib/zen/package/all')

Zen.post_init
