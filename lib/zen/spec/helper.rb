require 'ramaze'
require 'stringio'

Ramaze.setup(:verobse => false) do
  gem 'capybara', ['~> 1.0.0']
  gem 'bacon'   , ['~> 1.1.0']
end

require 'capybara/dsl'
require 'ramaze/spec/bacon'
require __DIR__('bacon/color_output')

Bacon.extend(Bacon::ColorOutput)

# Configure Capybara
Capybara.configure do |config|
  config.default_driver = :rack_test
  config.app            = Ramaze.middleware
end

##
# Logs the user in using the spec user.
#
# @author Yorick Peterse
# @since  0.2.8
#
def capybara_login
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

##
# Runs the block in a new thread and redirects $stdout and $stderr. The output
# normally stored in these variables is stored in an instance of StringIO which
# is returned as a hash.
#
# @example
#  out = catch_output do
#    puts 'hello'
#  end
#
# puts out # => {:stdout => "hello\n", :stderr => ""}
#
# @author Yorick Peterse
# @since  0.2.8
# @return [Hash]
#
def catch_output
  data = {
    :stdout => nil,
    :stderr => nil
  }

  Thread.new do
    $stdout, $stderr = StringIO.new, StringIO.new

    yield

    $stdout.rewind
    $stderr.rewind

    data[:stdout], data[:stderr] = $stdout.read, $stderr.read

    $stdout, $stderr = STDOUT, STDERR
  end.join

  return data
end

# Automatically log the user in before each specification
shared :capybara do
  Ramaze.setup_dependencies

  extend Capybara::DSL

  capybara_login
end

