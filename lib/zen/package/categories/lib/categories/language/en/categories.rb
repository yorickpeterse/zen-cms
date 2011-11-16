Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'categories'

  t['titles.index'] = 'Categories'
  t['titles.edit']  = 'Edit Category'
  t['titles.new']   = 'Add Category'

  t['labels.id']          = '#'
  t['labels.name']        = 'Name'
  t['labels.description'] = 'Description'
  t['labels.parent']      = 'Parent'
  t['labels.slug']        = 'Slug'

  t['descriptions.name'] = 'The name of the category'
  t['descriptions.slug'] = 'A URL friendly name of the category'

  t['messages.no_categories'] = 'No categories were found.'

  t['success.new']    = 'The category has been created.'
  t['success.save']   = 'The category has been modified.'
  t['success.delete'] = 'The selected categories have been deleted.'

  t['errors.new']       = 'Failed to add a new category.'
  t['errors.save']      = 'Failed to save the category.'
  t['errors.delete']    = 'Failed to delete the category with ID #%s.'
  t['errors.no_delete'] = 'You haven\'t specified any categories to delete.'
  t['errors.invalid_category'] = 'The specified category is invalid.'

  t['buttons.new']    = 'Add category'
  t['buttons.save']   = 'Save category'
  t['buttons.delete'] = 'Delete selected categories'

  t['permissions.show']   = 'Show category'
  t['permissions.edit']   = 'Edit category'
  t['permissions.new']    = 'Add category'
  t['permissions.delete'] = 'Delete category'
end
