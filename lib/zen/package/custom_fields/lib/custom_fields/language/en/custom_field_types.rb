# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'custom_field_types'

  trans.translate do |t|
    t['titles.index'] = 'Custom Field Types'
    t['titles.edit']  = 'Edit Custom Field Type'
    t['titles.new']   = 'Add Custom Field Type'

    t['labels.id']                     = '#'
    t['labels.name']                   = 'Name'
    t['labels.language_string']        = 'Language string'
    t['labels.html_class']             = 'HTML class'
    t['labels.serialize']              = 'Serialize'
    t['labels.allow_markup']           = 'Allow markup'
    t['labels.custom_field_method_id'] = 'Custom field method'

    t['descriptions.language_string'] = 'The full language string to use.'
    t['descriptions.html_class']      = 'A set of HTML classes to apply to ' \
      'all fields.'
    t['descriptions.serialize'] = 'Whether or not the value of a field ' \
      'has to be serialized.'
    t['descriptions.allow_markup'] = 'Whether or not markup, such as ' \
      'Markdown, can be used. '

    t['messages.no_field_types'] = 'No custom field types were found.'

    t['errors.new']    = 'The custom field type could not be added.'
    t['errors.save']   = 'The custom field type could not be modified.'
    t['errors.delete'] = 'The custom field type with ID #%s could not ' \
      'be removed.'
    t['errors.no_delete'] = 'You need to specify at least one custom ' \
      'field type to remove.'
    t['errors.invalid_type'] = 'The specified custom field type is invalid.'

    t['success.new']    = 'The custom field type has been added.'
    t['success.save']   = 'The custom field type has been modified.'
    t['success.delete'] = 'All selected custom field types have been removed.'

    t['buttons.new']    = 'Add field type'
    t['buttons.delete'] = 'Delete selected field types'
    t['buttons.save']   = 'Save field type'

    t['permissions.show']   = 'Show field type'
    t['permissions.edit']   = 'Edit field type'
    t['permissions.new']    = 'Add field type'
    t['permissions.delete'] = 'Delete field type'
  end
end
