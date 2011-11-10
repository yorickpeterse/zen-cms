require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe "Zen::Controller::Preview" do
  behaves_like :capybara

  should('convert Markdown to HTML') do
    markdown = 'Hello, **world**'
    response = page.driver.post(
      '/admin/preview', :engine => 'markdown', :markup => markdown
    )

    response.body.strip.should == '<p>Hello, <strong>world</strong></p>'
    response.status.should     == 200
  end

  should('convert an non existing markup type') do
    response = page.driver.post(
      '/admin/preview', :engine => 'foobar', :markup => 'foobar'
    )

    response.body.strip.should == lang('zen_general.errors.invalid_request')
    response.status.should     == 400
  end

  should('call without any parameters') do
    response = page.driver.post('/admin/preview')

    response.body.strip.should == lang('zen_general.errors.invalid_request')
    response.status.should     == 400
  end
end
