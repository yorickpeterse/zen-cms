require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe "Zen::Controller::Preview" do
  behaves_like :capybara

  it 'Convert Markdown to HTML via a POST request' do
    markdown = 'Hello, **world**'
    response = page.driver.post(
      '/admin/preview', :engine => 'markdown', :markup => markdown
    )

    response.body.strip.should == '<p>Hello, <strong>world</strong></p>'
    response.status.should     == 200
  end

  it 'Convert an non existing markup type using a POST request' do
    response = page.driver.post(
      '/admin/preview', :engine => 'foobar', :markup => 'foobar'
    )

    response.body.strip.should == lang('zen_general.errors.invalid_request')
    response.status.should     == 400
  end

  it 'Fail to convert markup without any POST parameters' do
    response = page.driver.post('/admin/preview')

    response.body.strip.should == lang('zen_general.errors.invalid_request')
    response.status.should     == 400
  end
end
