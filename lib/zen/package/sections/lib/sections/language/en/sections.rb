# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'sections'

  t['titles.index'] = 'Sections'
  t['titles.edit']  = 'Edit Section'
  t['titles.new']   = 'Add Secton'

  t['labels.id']                      = '#'
  t['labels.name']                    = 'Name'
  t['labels.slug']                    = 'Slug'
  t['labels.description']             = 'Description'
  t['labels.comment_allow']           = 'Allow comments'
  t['labels.comment_require_account'] = 'Comments require an account'
  t['labels.comment_moderate']        = 'Moderate comments'
  t['labels.comment_format']          = 'Comment format'
  t['labels.custom_field_groups']     = 'Custom field groups'
  t['labels.category_groups']         = 'Category groups'
  t['labels.manage_entries']          = 'Manage entries'

  t['special.boolean_hash.true']  = 'Yes'
  t['special.boolean_hash.false'] = 'No'

  t['tabs.general']           = 'General'
  t['tabs.comment_settings']  = 'Comment Settings'
  t['tabs.group_assignments'] = 'Group Assignments'

  t['messages.no_sections'] = 'No sections have been created yet.'

  t['errors.new']       = 'Failed to create a new section.'
  t['errors.save']      = 'Failed to modify the section.'
  t['errors.delete']    = 'Failed to delete the section with ID #%s.'
  t['errors.no_delete'] = 'You need to specify at least one ' \
    'section to delete.'
  t['errors.invalid_section'] = 'The specified section is invalid.'

  t['success.new']    = 'The new section has been created.'
  t['success.save']   = 'The section has been modified.'
  t['success.delete'] = 'The selected sections have been deleted.'

  t['buttons.new']    = 'Add section'
  t['buttons.delete'] = 'Delete selected sections'
  t['buttons.save']   = 'Save section'

  t['permissions.show']   = 'Show section'
  t['permissions.edit']   = 'Edit section'
  t['permissions.new']    = 'Add section'
  t['permissions.delete'] = 'Delete section'

  t['description'] = 'Manage sections and section entries.'
end
