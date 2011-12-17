# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'users'

  trans.translate do |t|
    t['titles.index']    = 'Users'
    t['titles.edit']     = 'Edit User'
    t['titles.new']      = 'Add User'
    t['titles.login']    = 'Login'
    t['titles.register'] = 'Register'

    t['labels.id']                 = '#'
    t['labels.email']              = 'Email'
    t['labels.name']               = 'Name'
    t['labels.website']            = 'Website'
    t['labels.password']           = 'Password'
    t['labels.confirm_password']   = 'Confirm password'
    t['labels.status']             = 'Status'
    t['labels.created_at']         = 'Created'
    t['labels.updated_at']         = 'Updated'
    t['labels.last_login']         = 'Last login'
    t['labels.user_groups']        = 'User groups'
    t['labels.language']           = 'Language'
    t['labels.frontend_language']  = 'Frontend language'
    t['labels.date_format']        = 'Date format'
    t['labels.allow_registration'] = 'Allow registration'

    t['descriptions.date_format'] = 'A custom format to use for all dates ' \
      'displayed in the backend.'
    t['descriptions.allow_registration'] = 'Allow non registered users to ' \
      'register a new account.'

    t['special.status_hash.active'] = 'Active'
    t['special.status_hash.closed'] = 'Closed'

    t['messages.no_users'] = 'No users were found.'

    t['errors.new']       = 'Failed to create the new user.'
    t['errors.save']      = 'Failed to save the user.'
    t['errors.delete']    = 'Failed to delete the user with ID #%s.'
    t['errors.no_delete']  = 'You have to specify at least one user to delete.'
    t['errors.no_password_match'] = 'The specified passwords did not match.'
    t['errors.login']   = 'Failed to log in with the specified details.'
    t['errors.logout']  = 'Failed to log out, perhaps you are already ' \
      'logged out.'
    t['errors.invalid_user'] = 'The specified user is invalid.'
    t['errors.register']     = 'The account could not be registered.'

    t['success.new']      = 'The new user has been created.'
    t['success.save']     = 'The user has been modified.'
    t['success.delete']   = 'All selected users have been deleted.'
    t['success.login']    = 'You have been successfully logged in.'
    t['success.logout']   = 'You have been successfully logged out.'
    t['success.register'] = 'The account has been registered.'

    t['buttons.login']    = 'Login'
    t['buttons.new']      = 'Add user'
    t['buttons.delete']   = 'Delete selected users'
    t['buttons.save']     = 'Save user'
    t['buttons.register'] = 'Confirm registration'

    t['description'] = 'Manage users, user groups and permissions.'

    t['permissions.show']   = 'Show user'
    t['permissions.edit']   = 'Edit user'
    t['permissions.new']    = 'Add user'
    t['permissions.delete'] = 'Delete user'

    t['tabs.settings'] = 'User Settings'
  end
end
