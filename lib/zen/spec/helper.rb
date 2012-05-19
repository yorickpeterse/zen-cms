require 'ramaze'

Ramaze.setup(:verbose => false) do
  gem 'capybara', ['>= 1.1.1']
  gem 'bacon'   , ['>= 1.1.0']
  gem 'webmock' , ['>= 1.8.7']
end

require 'capybara/dsl'
require 'ramaze/spec/bacon'

require __DIR__('helper/general')
require __DIR__('helper/capybara')

Bacon.extend(Bacon::TapOutput)

# Configure Capybara
Capybara.configure do |config|
  config.default_driver = :rack_test
  config.app            = Ramaze.middleware
end

shared :capybara do
  Ramaze.setup_dependencies
  extend Capybara::DSL
  extend WebMock::API
  extend Zen::Spec::Helper::Capybara
  extend Zen::Spec::Helper::General

  capybara_login
end
