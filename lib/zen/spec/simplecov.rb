require 'ramaze'

Ramaze.setup(:verbose => false) do
  gem 'simplecov', ['~> 0.4.2']
end

SimpleCov.configure do
  root         __DIR__('../../../')
  command_name 'bacon'
  project_name 'Zen'

  add_group 'Packages'   , 'zen/package'
  add_group 'Plugins'    , 'zen/plugin'
  add_group 'Helpers'    , 'zen/helper'
  add_group 'Controllers', 'zen/controller'

  # Don't actually test the coverage of the tests themselves
  add_filter 'spec'
  add_filter 'lib/zen/model/settings'
end

SimpleCov.start
