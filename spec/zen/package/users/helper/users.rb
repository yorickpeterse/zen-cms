require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Users') do
  behaves_like :capybara

  user = Users::Model::User.create(
    :email    => 'spec@spec.com',
    :name     => 'Spec user',
    :password => 'password'
  )

  group = Users::Model::UserGroup.create(
    :name        => 'Spec user group',
    :super_group => true
  )

  it('Validate a valid user') do
    url = Users::Controller::Users.r(:edit, user.id).to_s

    visit(url)

    current_path.should == url
  end

  it('Validate an invalid user') do
    url   = Users::Controller::Users.r(:edit, user.id + 1).to_s
    index = Users::Controller::Users.r(:index).to_s

    visit(url)

    current_path.should == index
  end

  it('Validate a valid user group') do
    url = Users::Controller::UserGroups.r(:edit, group.id).to_s

    visit(url)

    current_path.should == url
  end

  it('Validate an invalid user group') do
    url   = Users::Controller::UserGroups.r(:edit, group.id + 1).to_s
    index = Users::Controller::UserGroups.r(:index).to_s

    visit(url)

    current_path.should == index
  end

  group.destroy
  user.destroy
end
