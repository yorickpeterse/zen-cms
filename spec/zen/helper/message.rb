require File.expand_path('../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'helper', 'message')

describe('Ramaze::Helper::Message') do
  behaves_like :capybara

  should('display a success message') do
    visit('/admin/spec-message-helper/success')

    page.body.include?('success message').should == true
  end

  should('display an info message') do
    visit('/admin/spec-message-helper/info')

    page.body.include?('info message').should == true
  end

  should('display an error message') do
    visit('/admin/spec-message-helper/error')

    page.body.include?('error message').should == true
  end
end
