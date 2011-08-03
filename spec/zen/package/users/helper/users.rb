require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Users') do
  behaves_like :capybara

  it('Create the test data') do
    @user = Users::Model::User.create(
      :email    => 'spec@spec.com',
      :name     => 'Spec user',
      :password => 'password'
    )

    @group = Users::Model::UserGroup.create(
      :name        => 'Spec user group',
      :super_group => true
    )

    @rule = Users::Model::AccessRule.create(
      :package       => 'sections',
      :controller    => '*',
      :create_access => true,
      :read_access   => true,
      :delete_access => true,
      :update_access => true,
      :user_id       => @user.id
    )

    @user.email.should   === 'spec@spec.com'
    @group.name.should   === 'Spec user group'
    @rule.package.should === 'sections'
    @rule.user_id.should === @user.id
  end

  it('Validate a valid user') do
    url = Users::Controller::Users.r(:edit, @user.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid user') do
    url   = Users::Controller::Users.r(:edit, @user.id + 1).to_s
    index = Users::Controller::Users.r(:index).to_s

    visit(url)

    current_path.should === index
  end

  it('Validate a valid user group') do
    url = Users::Controller::UserGroups.r(:edit, @group.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid user group') do
    url   = Users::Controller::UserGroups.r(:edit, @group.id + 1).to_s
    index = Users::Controller::UserGroups.r(:index).to_s

    visit(url)

    current_path.should === index
  end

  it('Validate a valid access rule') do
    url = Users::Controller::AccessRules.r(:edit, @rule.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid access rule') do
    url   = Users::Controller::AccessRules.r(:edit, @rule.id + 1).to_s
    index = Users::Controller::AccessRules.r(:index).to_s

    visit(url)

    current_path.should === index
  end

  it('Delete the test data') do
    id = @user.id

    @rule.destroy
    @group.destroy
    @user.destroy

    Users::Model::User[:name => 'Spec user'].should            === nil
    Users::Model::UserGroup[:name => 'Spec user group'].should === nil
    Users::Model::AccessRule[:user_id => id].should            === nil
  end

end
