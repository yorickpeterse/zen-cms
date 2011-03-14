require_relative('../../../helper')

describe("Users::Controllers::Users", :type => :acceptance) do

  it 'Show the login form' do
    login_url = Users::Controllers::Users.r(:login).to_s

    visit(login_url)

    # Verify if the form is really there
    page.has_selector?('#login_form').should == true
    page.has_selector?('input[type="submit"][value="Login"]').should == true
    page.has_content?('Email').should == true
    page.has_content?('Password').should == true 
  end

  it('Log in') do
    login_url     = Users::Controllers::Users.r(:login).to_s
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
    users_url = Users::Controllers::UserGroups.r(:index).to_s
    login_url = Users::Controllers::Users.r(:login).to_s

    visit(users_url)
    
    current_path.should == login_url
  end

end
