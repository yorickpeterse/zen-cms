Zen::Language.translation 'users' do |item|
  # Page titles
  item.titles = {
    :index  => 'Users',
    :edit   => 'Edit User',
    :new    => 'Add User',
    :login  => 'Login'
  }
  
  # Labels
  item.labels = {
    :id               => '#',
    :email            => 'Email',
    :name             => 'Name',
    :website          => 'Website',
    :password         => 'Password',
    :new_password     => 'New password',
    :confirm_password => 'Confirm password',
    :status           => 'Status',
    :created_at       => 'Created',
    :updated_at       => 'Updated',
    :last_login       => 'Last login',
    :user_groups      => 'User groups'
  }
  
  # Special items such as sub hashes and such
  item.special = {
    :status_hash => {'open' => 'Open', 'closed' => 'Closed'}
  }

  # General messages
  item.messages = {
    :no_users    => 'No users have been added yet'
  }
  
  # Error specific messages
  item.errors = {
    :new               => "Failed to create a new users.",
    :save              => "Failed to save the user.",
    :delete            => "Failed to delete the user with ID #%s",
    :no_delete         => "You haven't specified any users to delete.",
    :no_password_match => 'The specified passwords didn\'t match.',
    :login             => "Failed to login with the specified details",
    :logout            => "Failed to log out, what the hell is going on?"
  }
  
  # Success messages
  item.success = {
    :new    => "The new user has been created.",
    :save   => "The user has been modified.",
    :delete => "The user with ID #%s has been deleted.",
    :login  => "You've been successfully logged in.",
    :logout => "You've been successfully logged out."
  }
  
  # Buttons
  item.buttons = {
    :login        => 'Login',
    :new_user     => 'New user',
    :delete_users => 'Delete selected users',
    :save_user    => 'Save user'
  }
end