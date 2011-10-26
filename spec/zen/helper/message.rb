require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/helper/message')

describe('Ramaze::Helper::Message') do
  behaves_like :capybara

  it('Display a success message') do
    visit('/admin/spec-message-helper/success')

    page.body.include?('success message').should == true
  end

  it('Display an info message') do
    visit('/admin/spec-message-helper/info')

    page.body.include?('info message').should == true
  end

  it('Display an error message') do
    visit('/admin/spec-message-helper/error')

    page.body.include?('error message').should == true
  end
end
