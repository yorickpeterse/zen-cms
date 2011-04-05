require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('users')

describe("Users::Controllers::Users", :type => :acceptance) do
  include Users::Controllers

  it 'Show the login form' do
    login_url = Users.r(:login).to_s

    visit(login_url)

    # Verify if the form is really there
    page.has_selector?('#login_form').should == true
    page.has_selector?('input[type="submit"][value="Login"]').should == true
    page.has_content?('Email').should == true
    page.has_content?('Password').should == true 
  end

  it('Log in') do
    login_url     = Users.r(:login).to_s
    dashboard_url = Sections::Controllers::Sections.r(:index).to_s

    visit(login_url)

    # Try to log in
    within('#login_form') do
      fill_in 'Email'   , :with => 'spec@domain.tld'
      fill_in 'Password', :with => 'spec'
      click_button 'Login'
    end

    # We can only access the dashboard if we're logged in
    current_path.should == dashboard_url
  end

  it('Access an unauthorized URL') do
    users_url = UserGroups.r(:index).to_s
    login_url = Users.r(:login).to_s

    visit(users_url)
    
    current_path.should == login_url
  end

  it("A user should exist", :auto_login => true) do
    index_url = Users.r(:index).to_s
    message   = lang('users.messages.no_users')

    visit(index_url)

    page.has_selector?('table tbody tr').should === true
    page.has_content?(message).should           === false
  end

  it("Create a new user", :auto_login => true) do
    index_url   = Users.r(:index).to_s
    save_button = lang('users.buttons.save')
    new_button  = lang('users.buttons.new')
    status      = lang('users.special.status_hash.open')

    visit(index_url)
    click_link(new_button)

    within('#user_form') do
      fill_in('name'   , :with => 'Spec user')
      fill_in('email'  , :with => 'spec@email.com') 
      fill_in('website', :with => 'spec.com')
      fill_in('new_password'    , :with => 'spec')
      fill_in('confirm_password', :with => 'spec')
      select(status, :from => 'status')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should  === 'Spec user'
    page.find('input[name="email"]').value.should === 'spec@email.com'
  end

  it("Edit an existing user", :auto_login => true) do
    index_url   = Users.r(:index).to_s
    save_button = lang('users.buttons.save')

    visit(index_url)
    click_link('spec@email.com')

    within('#user_form') do
      fill_in('name', :with => 'Spec user modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should  === 'Spec user modified'
  end

  it("Delete an existing user", :auto_login => true) do
    index_url     = Users.r(:index).to_s
    delete_button = lang('users.buttons.delete')

    visit(index_url)

    within('table tbody tr:last-child') do
      check('user_ids[]')
    end

    click_on(delete_button)

    page.has_content?('spec@email.com').should === false
  end

end
