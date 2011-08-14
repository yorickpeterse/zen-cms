require 'ramaze'
require 'stringio'

Ramaze.setup(:verobse => false) do
  gem 'capybara', ['~> 1.0.1']
  gem 'bacon'   , ['~> 1.1.0']
  gem 'webmock' , ['~> 1.6.4']
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
#  puts out # => {:stdout => "hello\n", :stderr => ""}
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

##
# Allows developers to create stubbed objects similar to Mocha's stub() method.
#
# @example
#  obj = stub(:language => 'Ruby')
#  puts obj.language # => "Ruby"
#
# @author Yorick Peterse
# @since  0.2.8
# @param  [Hash] attributes A hash containing all the attributes to set and
# their values.
# @return [Class]
#
def stub(attributes)
  obj = Struct.new(*attributes.keys).new

  attributes.each do |k, v|
    obj.send("#{k}=", v)
  end

  return obj
end

##
# Returns a hash with a stubbed custom field and a stubbed custom field value.
#
# @author Yorick Peterse
# @since  0.2.8
# @param  [String] field_type_name The name of the field type.
# @param  [Hash] options Additional options to pass to the stub() call for the
# custom field.
# @return [Hash]
#
def stub_custom_field(field_type_name, options = {})
  custom_field_type = CustomFields::Model::CustomFieldType[
    :name => field_type_name
  ]

  options = {
    :id                    => 1,
    :name                  => 'Field',
    :slug                  => 'field',
    :description           => 'A stubbed field',
    :sort_order            => 0,
    :format                => 'markdown',
    :required              => false,
    :text_editor           => false,
    :textarea_rows         => nil,
    :text_limit            => 100,
    :custom_field_group_id => 1,
    :custom_field_type_id  => custom_field_type.id,
    :custom_field_type     => custom_field_type
  }.merge(options)

  return {
    :custom_field       => stub(options),
    :custom_field_value => stub(
      :id               => 1,
      :value            => 'Ruby',
      :custom_field_id  => 1,
      :section_entry_id => 1
    )
  }
end

shared :capybara do
  Ramaze.setup_dependencies
  extend Capybara::DSL
  extend WebMock::API

  capybara_login
end
