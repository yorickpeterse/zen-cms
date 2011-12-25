# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'user_groups'

  trans.translate do |t|
    t['titles.index'] = 'User Groups'
    t['titles.edit']  = 'Edit User Group'
    t['titles.new']   = 'Add User Group'

    t['labels.id']          = '#'
    t['labels.name']        = 'Name'
    t['labels.slug']        = 'Slug'
    t['labels.description'] = 'Description'
    t['labels.super_group'] = 'Super group'

    t['messages.no_groups'] = 'No user groups were found.'

    t['errors.new']           = 'Failed to create a new user group.'
    t['errors.save']          = 'Failed to modify the user group.'
    t['errors.delete']        = 'Failed to delete the user group with ID #%s.'
    t['errors.no_delete']     = 'You have to specify at least one group to delete.'
    t['errors.invalid_group'] = 'The specified user group is invalid.'

    t['success.new']    = 'The new user group has been created.'
    t['success.save']   = 'The user group has been modified.'
    t['success.delete'] = 'All selected user groups have been deleted.'

    t['buttons.new']    = 'New group'
    t['buttons.delete'] = 'Delete selected groups'
    t['buttons.save']   = 'Save group'

    t['permissions.show']   = 'Show group'
    t['permissions.edit']   = 'Edit group'
    t['permissions.new']    = 'Add group'
    t['permissions.delete'] = 'Delete group'
    t['permissions.assign'] = 'Assign group'
  end
end
