require File.expand_path('../../lib/zen', __FILE__)
require File.expand_path('../../lib/zen/spec/bacon/color_output', __FILE__)

Ramaze.setup(:verbose => false) do
  gem 'bacon'    , ['~> 1.1.0']
  gem 'capybara' , ['~> 1.0.0']
  gem 'sqlite3'  , ['~> 1.3.3']
  gem 'rdiscount', ['~> 1.6.8']
  gem 'RedCloth' , ['~> 4.2.7']
  gem 'defensio' , ['~> 0.9.1']
end

require 'ramaze/spec/bacon'
require 'capybara/dsl'

Bacon.extend(Bacon::ColorOutput)

# Update all paths
Ramaze.options.roots = [__DIR__]
Ramaze.options.mode  = :spec
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

# Configure Capybara
Capybara.configure do |config|
  config.default_driver = :rack_test
  config.app            = Ramaze.middleware
end

# Automatically log the user in before each specification
shared :capybara do
  Ramaze.setup_dependencies

  extend Capybara::DSL

  # Log the user in
  login_url     = ::Users::Controller::Users.r(:login).to_s
  dashboard_url = ::Sections::Controller::Sections.r(:index).to_s

  visit(login_url)
  ::Ramaze::Log.loggers.clear

  within('#login_form') do
    fill_in('Email'   , :with => 'spec@domain.tld')
    fill_in('Password', :with => 'spec')
    click_button('Login')
  end
end

# Method that can be used to load a number of fixtures from fixtures/zen
def fixtures(fixtures)
  fixtures.each do |f|
    require File.expand_path("../fixtures/zen/#{f}", __FILE__)
  end
end
