require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/helper/message')

describe('Ramaze::Helper::Message') do
  behaves_like :capybara

  it('Display a success message') do
    # Initialize the session
    visit('/admin/spec-message-helper')

    visit('/admin/spec-message-helper/success')
    visit('/admin/spec-message-helper')

    page.body.include?('success message').should === true
  end

  it('Display an info message') do
    visit('/admin/spec-message-helper/info')
    visit('/admin/spec-message-helper')

    page.body.include?('info message').should === true
  end

  it('Display an error message') do
    visit('/admin/spec-message-helper/error')
    visit('/admin/spec-message-helper')

    page.body.include?('error message').should === true
  end

end
