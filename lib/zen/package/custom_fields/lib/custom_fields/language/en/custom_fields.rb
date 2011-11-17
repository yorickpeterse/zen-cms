# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'custom_fields'

  trans.translate do |t|
    t['titles.index'] = 'Custom Fields'
    t['titles.edit']  = 'Edit Custom Field'
    t['titles.new']   = 'Add Custom Field'

    t['labels.id']                   = '#'
    t['labels.name']                 = 'Name'
    t['labels.slug']                 = 'Slug'
    t['labels.format']               = 'Format'
    t['labels.description']          = 'Description'
    t['labels.possible_values']      = 'Possible values (one value per line)'
    t['labels.required']             = 'Requires a value'
    t['labels.text_editor']          = 'Enable a text editor'
    t['labels.textarea_rows']        = 'Textarea rows'
    t['labels.text_limit']           = 'Character limit'
    t['labels.sort_order']           = 'Sort order'
    t['labels.custom_field_type_id'] = 'Field type'

    t['tabs.general']  = 'General'
    t['tabs.settings'] = 'Settings'

    t['messages.no_fields'] = 'No custom fields were found.'

    t['errors.new']       = 'Failed to create the new custom field.'
    t['errors.save']      = 'Failed to modify the custom field.'
    t['errors.delete']    = 'Failed to delete the custom field with ID #%s.'
    t['errors.no_delete'] = 'You haven\'t specified any custom fields to delete.'
    t['errors.invalid_field'] = 'The specified custom field is invalid.'

    t['success.new']    = 'The new custom field has been created.'
    t['success.save']   = 'The custom field has been modified.'
    t['success.delete'] = 'The selected custom fields have been deleted.'
    t['special.type_hash.textbox'] = 'Textbox'

    t['special.type_hash.textarea']        = 'Textarea'
    t['special.type_hash.radio']           = 'Radio button'
    t['special.type_hash.checkbox']        = 'Checkbox'
    t['special.type_hash.date']            = 'Date'
    t['special.type_hash.select']          = 'Select dropdown'
    t['special.type_hash.select_multiple'] = 'Multi select'
    t['special.type_hash.password']        = 'Password'

    t['buttons.new']    = 'Add custom field'
    t['buttons.delete'] = 'Delete selected fields'
    t['buttons.save']   = 'Save custom field'

    t['permissions.show']   = 'Show custom field'
    t['permissions.edit']   = 'Edit custom field'
    t['permissions.new']    = 'Add custom field'
    t['permissions.delete'] = 'Delete custom field'

    t['description'] = 'Manage custom fields, field groups and field types.'
  end
end
