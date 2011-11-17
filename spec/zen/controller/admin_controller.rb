require File.expand_path('../../../helper', __FILE__)
require 'rdiscount'

describe('Zen::Controller::AdminController') do
  behaves_like :capybara

  it('Deny access to an admin URL when not logged in') do
    logout = Users::Controller::Users.r(:logout).to_s
    url    = Categories::Controller::CategoryGroups.r(:index).to_s

    visit(logout)
    visit(url)

    current_path.should == Users::Controller::Users.r(:login).to_s
  end

  it('Access an admin URL when logged in') do
    url = Categories::Controller::CategoryGroups.r(:index).to_s

    capybara_login
    visit(url)

    current_path.should == url
  end
end
