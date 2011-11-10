require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe('Zen::Controller::Preview') do
  behaves_like :capybara

  should('access a non authorized URL') do
    logout = Users::Controller::Users.r(:logout).to_s
    url    = Categories::Controller::CategoryGroups.r(:index).to_s

    visit(logout)
    visit(url)

    current_path.should == Users::Controller::Users.r(:login).to_s
  end

  should('access an authorized URL') do
    url = Categories::Controller::CategoryGroups.r(:index).to_s

    capybara_login
    visit(url)

    current_path.should == url
  end
end
