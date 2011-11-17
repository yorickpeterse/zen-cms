require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package', 'users', 'helper', 'acl')

describe('Ramaze::Helper::ACL') do
  behaves_like :capybara

  visit(Users::Controller::Users.r(:logout).to_s)

  # Update the permissions before logging in as they're cached in the session.
  Users::Model::User[:email => 'spec@domain.tld'] \
    .add_permission(:permission => 'spec_permission')

  Users::Model::UserGroup[:slug => 'administrators'] \
    .update(:super_group => false)

  capybara_login

  it('Allow for a permission') do
    visit('/admin/spec-acl-helper')

    page.has_content?('not allowed').should == false
    page.has_content?('allowed').should     == true
  end

  it('Deny for a missing permission') do
    visit('/admin/spec-acl-helper/invalid')

    page.has_content?('not allowed').should == true
  end

  it('Respond for a missing permission') do
    visit('/admin/spec-acl-helper/respond_message')

    page.has_content?(lang('zen_general.errors.not_authorized')).should == true
    page.status_code.should == 403
  end

  Zen.database[:permissions] \
    .filter(:permission => 'spec_permission') \
    .delete

  Users::Model::UserGroup[:slug => 'administrators'] \
    .update(:super_group => true)

  Ramaze::Cache.session.clear
end
