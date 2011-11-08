require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package', 'users', 'helper', 'access')

describe('Ramaze::Helper::Access') do
  behaves_like :capybara

  visit(Users::Controller::Users.r(:logout).to_s)

  it('Deny access to a method') do
    visit('/admin/spec-access-helper/denied')

    current_path.should == Users::Controller::Users.r(:login).to_s
    page.body.include?('super secret page').should == false
  end

  it('Allow access to a list of methods') do
    capybara_login

    visit('/admin/spec-access-helper/allowed')

    current_path.should                  == SpecAccessHelper.r(:allowed).to_s
    page.body.include?('allowed').should == true

    visit('/admin/spec-access-helper/allowed_1')

    current_path.should                  == SpecAccessHelper.r(:allowed_1).to_s
    page.body.include?('allowed').should == true
  end
end
