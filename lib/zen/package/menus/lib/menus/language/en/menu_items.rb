# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'menu_items'

  t['titles.index'] = 'Menu Items'
  t['titles.edit']  = 'Edit Menu Item'
  t['titles.new']   = 'Create Menu Item'

  t['labels.id']         = '#'
  t['labels.parent_id']  = 'Parent'
  t['labels.name']       = 'Name'
  t['labels.url']        = 'URL'
  t['labels.order']      = 'Order'
  t['labels.html_class'] = 'HTML class'
  t['labels.html_id']    = 'HTML ID'

  t['descriptions.name']       = 'The text that will be displayed in the link.'
  t['descriptions.url']        = 'The location to which the link will point.'
  t['descriptions.order']      = 'A number that indicates the sort order.'
  t['descriptions.html_id']    = 'Specify an ID to apply to this item.'
  t['descriptions.html_class'] = 'Specify a class name (or multiple names) ' \
    'to apply to this item.'

  t['messages.no_items'] = 'No menu items were found.'

  t['buttons.new']    = 'Add menu item'
  t['buttons.save']   = 'Save menu item'
  t['buttons.delete'] = 'Delete selected menu items'

  t['success.new']    = 'The menu item has been created.'
  t['success.save']   = 'The menu item has been modified.'
  t['success.delete'] = 'The selected menu items have been deleted.'

  t['errors.new']          = 'The menu item could not be created.'
  t['errors.save']         = 'The menu item could not be modified.'
  t['errors.delete']       = 'The menu item with ID #%s could not be deleted.'
  t['errors.no_delete']    = 'You need to specify at least one item to delete.'
  t['errors.invalid_item'] = 'The specified menu item is invalid.'

  t['permissions.show']   = 'Show menu item'
  t['permissions.edit']   = 'Edit menu item'
  t['permissions.new']    = 'Add menu item'
  t['permissions.delete'] = 'Delete menu item'
end
