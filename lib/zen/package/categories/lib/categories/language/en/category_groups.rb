Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'category_groups'

  t['titles.index'] = 'Category Groups'
  t['titles.edit']  = 'Edit Category'
  t['titles.new']   = 'Add Category Group'

  t['labels.id']          = '#'
  t['labels.name']        = 'Name'
  t['labels.description'] = 'Description'
  t['labels.manage']      = 'Manage categories'

  t['descriptions.name']  = 'The name of the category group'
  t['messages.no_groups'] = 'No category groups were found.'

  t['success.new']    = 'The category group has been created.'
  t['success.save']   = 'The category group has been modified.'
  t['success.delete'] = 'All selected category groups have been deleted.'

  t['errors.new']           = 'Failed to add the new category group.'
  t['errors.save']          = 'Failed to modify the category group.'
  t['errors.delete']        = 'Failed to delete the category group with ID #%s.'
  t['errors.invalid_group'] = 'The specified group is invalid.'

  t['buttons.new']    = 'Add group'
  t['buttons.save']   = 'Save group'
  t['buttons.delete'] = 'Delete selected groups'

  t['permissions.show']   = 'Show category group'
  t['permissions.edit']   = 'Edit category group'
  t['permissions.new']    = 'Add category group'
  t['permissions.delete'] = 'Delete group'

  t['description'] = 'Managing categories and category groups.'
end
