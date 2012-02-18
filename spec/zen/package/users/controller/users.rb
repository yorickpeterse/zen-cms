require File.expand_path('../../../../../helper', __FILE__)

describe "Users::Controller::Users" do
  behaves_like :capybara

  login_url     = Users::Controller::Users.r(:login).to_s
  dashboard_url = Dashboard::Controller::Dashboard.r(:index).to_s
  index_url     = Users::Controller::Users.r(:index).to_s
  save_button   = lang('users.buttons.save')
  new_button    = lang('users.buttons.new')
  delete_button = lang('users.buttons.delete')
  status        = lang('users.special.status_hash.active')

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      Users::Controller::Users.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Show the login form' do
    visit(login_url)

    page.has_selector?('#login_form').should                         == true
    page.has_selector?('input[type="submit"][value="Login"]').should == true
    page.has_content?('Email').should                                == true
    page.has_content?('Password').should                             == true
  end

  it 'Log in' do
    event_email = nil

    Zen::Event.listen(:user_login) do |user|
      event_email = user.email
    end

    visit(login_url)

    within '#login_form' do
      fill_in 'Email'   , :with => 'spec@domain.tld'
      fill_in 'Password', :with => 'spec'
      click_button 'Login'
    end

    current_path.should == dashboard_url
    event_email.should  == 'spec@domain.tld'
  end

  it 'Find an existing user' do
    message = lang('users.messages.no_users')

    visit(index_url)

    page.has_selector?('table tbody tr').should == true
    page.has_content?(message).should           == false
  end

  it "Create a new user" do
    visit(index_url)
    click_link(new_button)

    within '#user_form' do
      fill_in('name'   , :with => 'Spec user')
      fill_in('email'  , :with => 'spec@email.com')
      fill_in('website', :with => 'spec.com')
      fill_in('password'        , :with => 'spec')
      fill_in('confirm_password', :with => 'spec')

      select(status, :from => 'user_status_id')
      click_on(save_button)
    end

    page.has_selector?('span.error').should       == false
    page.find('input[name="name"]').value.should  == 'Spec user'
    page.find('input[name="email"]').value.should == 'spec@email.com'
  end

  it 'Search for a user' do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within '#search_form' do
      fill_in('query', :with => 'Spec user')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec user').should == true

    within '#search_form' do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec user').should == false
  end

  it "Edit an existing user" do
    visit(index_url)
    click_link('Spec user')

    within '#user_form' do
      fill_in('name', :with => 'Spec user modified')
      check('permission_show_user')
      check('form_user_group_pks_0')
      click_on(save_button)
    end

    page.find('#permission_show_user').checked?.should  == 'checked'
    page.find('#form_user_group_pks_0').checked?.should == 'checked'
    page.find_field('name').value.should                == 'Spec user modified'

    user  = Users::Model::User[:email => 'spec@email.com']
    group = Users::Model::UserGroup[:slug => 'administrators']

    user.user_group_pks.include?(group.id).should == true
  end

  it 'Remove a permission from a user' do
    visit(index_url)
    click_link('Spec user')

    within '#user_form' do
      uncheck('permission_show_user')
      click_on(save_button)
    end

    page.find('#permission_show_user').checked?.should != 'checked'
  end

  it "Edit an existing user with invalid data" do
    visit(index_url)
    click_link('Spec user')

    within '#user_form' do
      fill_in('form_name', :with => '')
      click_on(save_button)
    end

    page.find_field('form_name').value.empty?.should               == true
    page.has_selector?('label[for="form_name"] span.error').should == true
  end

  it "Delete an existing user without specifying an ID" do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="user_ids[]"]').should == true
  end

  it "Delete an existing user" do
    visit(index_url)

    within 'table tbody tr:last-child' do
      check('user_ids[]')
    end

    click_on(delete_button)

    page.has_content?('spec@email.com').should == false
  end

  it 'Call the event new_user (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_new_user) do |user|
      user.name += ' with event'
    end

    Zen::Event.listen(:after_new_user) do |user|
      event_name = user.name
    end

    visit(index_url)
    click_on(new_button)

    within '#user_form' do
      fill_in('name'   , :with => 'User')
      fill_in('email'  , :with => 'spec@email.com')
      fill_in('website', :with => 'spec.com')
      fill_in('password'        , :with => 'spec')
      fill_in('confirm_password', :with => 'spec')

      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'User with event'
    event_name.should                            == 'User with event'

    Zen::Event.delete(:before_new_user, :after_new_user)
  end

  it 'Call the event edit_user (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_edit_user) do |user|
      user.name = 'User modified'
    end

    Zen::Event.listen(:after_edit_user) do |user|
      event_name = user.name
    end

    visit(index_url)
    click_on('User with event')

    within '#user_form' do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'User modified'
    event_name.should                            == 'User modified'

    Zen::Event.delete(:before_edit_user, :after_edit_user)
  end

  it 'Call the event delete_user (before and after)' do
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_delete_user) do |user|
      event_name = user.name
    end

    Zen::Event.listen(:after_delete_user) do |user|
      event_name2 = user.name
    end

    visit(index_url)

    within 'table tbody tr:last-child' do
      check('user_ids[]')
    end

    click_on(delete_button)

    page.has_content?('User modified').should == false
    event_name.should                         == 'User modified'
    event_name2.should                        == event_name

    Zen::Event.delete(:before_delete_user, :after_delete_user)
  end

  it 'Register a new user' do
    get_setting(:allow_registration).value = '1'

    logout_path   = Users::Controller::Users.r(:logout).to_s
    login_path    = Users::Controller::Users.r(:login).to_s
    register_path = Users::Controller::Users.r(:register).to_s

    visit(logout_path)
    visit(register_path)

    current_path.should == register_path

    within '#register_form' do
      fill_in('name', :with => 'New user')
      fill_in('email', :with => 'test@test.com')
      fill_in('password', :with => 'abc')
      fill_in('confirm_password', :with => 'abc')
      click_on(lang('users.buttons.register'))
    end

    page.has_selector?('span.error').should == false
    current_path.should                     == login_path

    user = Users::Model::User[:email => 'test@test.com']

    user.nil?.should             == false
    user.user_status.name.should == 'closed'
  end

  it 'Allow users to edit their own account' do
    user       = Users::Model::User[:email => 'test@test.com']
    edit_url   = Users::Controller::Users.r(:edit, user.id).to_s
    logout_url = Users::Controller::Users.r(:logout).to_s

    user.activate!

    visit(logout_url)
    visit(Users::Controller::Users.r(:login).to_s)

    # Log in as the user created in the previous tests.
    within '#login_form' do
      fill_in('Email', :with => 'test@test.com')
      fill_in('Password', :with => 'abc')
      click_button('Login')
    end

    visit(edit_url)

    current_path.should == edit_url

    within '#user_form' do
      fill_in('name', :with => 'Modified user')
      click_on(save_button)
    end

    user.reload

    current_path.should                                         == edit_url
    page.has_selector?('span.error').should                     == false
    page.has_selector?('select[name="user_status_id"]').should  == false
    page.has_selector?('input[name="user_group_pks[]"]').should == false

    page.find('input[name="name"]').value.should == 'Modified user'
    user.name.should                             == 'Modified user'
    user.user_group_pks.empty?.should            == true

    visit(logout_url)
  end

  capybara_login
  Users::Model::User[:email => 'test@test.com'].destroy
end
