require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/helper/acl')

describe('Ramaze::Helper::ACL') do
  behaves_like :capybara

  # Ensure that no custom access rules exist.
  after do
    Users::Model::AccessRule.destroy
  end

  # Check if all the controllers are there and if the user has full access.
  it('Get all extension permissions') do
    visit('/admin/spec-acl-helper')

    ::Zen::Package::Controllers.each do |c|
      c = c.to_s
      SpecACLHelper::SpecData[:permissions].key?(c).should === true

      [:create, :read, :update, :delete].each do |perm|
        SpecACLHelper::SpecData[:permissions][c].include?(perm).should === true
      end
    end
  end

  # In this test the user does not have access to Users::Controller::Users and
  # thus the rules array should be empty.
  it('Get all permissions with limited access') do
    rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => false,
      :read_access   => false,
      :update_access => false,
      :delete_access => false,
      :user_id       => Users::Model::User[:email => 'spec@domain.tld'].id
    )

    visit('/admin/spec-acl-helper')

    SpecACLHelper::SpecData[:permissions]['Users::Controller::Users'].empty? \
      .should === true

    rule.destroy
  end

  it('User rules should overwrite group rules') do
    group_rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => true,
      :read_access   => true,
      :update_access => false,
      :delete_access => false,
      :user_group_id => Users::Model::UserGroup[:slug => 'administrators'].id
    )

    user_rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => false,
      :read_access   => false,
      :update_access => true,
      :delete_access => true,
      :user_id       => Users::Model::User[:email => 'spec@domain.tld'].id
    )

    visit('/admin/spec-acl-helper')

    [:create, :read].each do |perm|
      SpecACLHelper::SpecData[:permissions]['Users::Controller::Users'] \
        .include?(perm).should === false
    end

    [:update, :delete].each do |perm|
      SpecACLHelper::SpecData[:permissions]['Users::Controller::Users'] \
        .include?(perm).should === true
    end

    group_rule.destroy
    user_rule.destroy
  end

  # Checks if the user is authorized to access a page if it has access to all
  # the given requirements as well as when he/she has access to only one of
  # them.
  it('Requiring specific and all rules') do
    rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => true,
      :read_access   => true,
      :update_access => false,
      :delete_access => false,
      :user_id       => Users::Model::User[:email => 'spec@domain.tld'].id
    )

    # Check if the user has all the required rules
    visit('/admin/spec-acl-helper/require_all')

    page.body.include?('authorized').should     === true
    page.body.include?('not authorized').should === false

    # Check if the user has one of the required rules
    visit('/admin/spec-acl-helper/require_one')

    page.body.include?('authorized').should     === true
    page.body.include?('not authorized').should === false

    rule.destroy
  end

  it('Use user_authorized?() to block a user') do
    rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => false,
      :read_access   => false,
      :update_access => false,
      :delete_access => false,
      :user_id       => Users::Model::User[:email => 'spec@domain.tld'].id
    )

    visit('/admin/spec-acl-helper/require_all')

    page.body.include?('not authorized').should === true

    rule.destroy
  end

  it('Use require_permissions() to block a user') do
    rule = Users::Model::AccessRule.create(
      :package       => 'users',
      :controller    => 'Users::Controller::Users',
      :create_access => true,
      :read_access   => true,
      :update_access => false,
      :delete_access => false,
      :user_id       => Users::Model::User[:email => 'spec@domain.tld'].id
    )

    visit('/admin/spec-acl-helper/require_permissions_block')

    page.body.include?(lang('zen_general.errors.not_authorized')) \
      .should === true

    page.status_code.should === 403
  end
end
