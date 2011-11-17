# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'menus'

  t['titles.index'] = 'Menus'
  t['titles.edit']  = 'Edit Menu'
  t['titles.new']   = 'Add Menu'

  t['labels.id']           = '#'
  t['labels.name']         = 'Name'
  t['labels.slug']         = 'Slug'
  t['labels.description']  = 'Description'
  t['labels.html_class']   = 'HTML class'
  t['labels.html_id']      = 'HTML ID'
  t['labels.manage_items'] = 'Manage menu items'

  t['descriptions.name']       = 'Specify the name of the menu.'
  t['descriptions.slug']       = 'Specify the URL friendly name of the menu.'
  t['descriptions.html_class'] = 'A number of classes to apply to the menu.'
  t['descriptions.html_id']    = 'An ID to apply to the menu.'

  t['messages.no_menus'] = 'No menus were found.'

  t['buttons.new']    = 'Add menu'
  t['buttons.save']   = 'Save menu'
  t['buttons.delete'] = 'Delete selected menus'

  t['success.new']    = 'The menu has been created.'
  t['success.save']   = 'The menu has been modified.'
  t['success.delete'] = 'The selected menus have been deleted.'

  t['errors.new']          = 'The menu could not be created.'
  t['errors.save']         = 'The menu could not be modified.'
  t['errors.delete']       = 'The menu with ID #%s could not be deleted.'
  t['errors.no_delete']    = 'You need to specify at least one menu to delete.'
  t['errors.invalid_menu'] = 'The specified menu is invalid.'

  t['permissions.show']   = 'Show menu'
  t['permissions.edit']   = 'Edit menu'
  t['permissions.new']    = 'Add menu'
  t['permissions.delete'] = 'Delete menu'

  t['description'] = 'Manage menus and menu items.'
end
