# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'section_entries'

  t['titles.index'] = 'Section Entries'
  t['titles.edit']  = 'Edit Entry'
  t['titles.new']   = 'Add Entry'

  t['labels.id']         = '#'
  t['labels.title']      = 'Title'
  t['labels.slug']       = 'Slug'
  t['labels.status']     = 'Status'
  t['labels.created_at'] = 'Created at'
  t['labels.updated_at'] = 'Updated at'
  t['labels.author']     = 'Author'

  t['special.status_hash.draft']     = 'Draft'
  t['special.status_hash.published'] = 'Published'

  t['tabs.basic']      = 'Basic'
  t['tabs.categories'] = 'Categories'

  t['messages.no_entries']    = 'No section entries were found.'
  t['messages.no_categories'] = 'No categories have been assigned to the '\
    'current section.'

  t['errors.new']           = 'Failed to create a new section entry.'
  t['errors.save']          = 'Failed to save the section entry.'
  t['errors.delete']        = 'Failed to delete the section entry with ID#%s'
  t['errors.no_delete']     = 'You haven\'t specified any section '\
    'entries to delete.'
  t['errors.invalid_entry'] = 'The specified entry is invalid.'

  t['success.new']    = 'The new section entry has been created.'
  t['success.save']   = 'The section entry has been modified.'
  t['success.delete'] = 'All selected entries have been deleted.'

  t['buttons.new']    = 'Add section entry'
  t['buttons.delete'] = 'Delete selected entries'
  t['buttons.save']   = 'Save entry'

  t['permissions.show']   = 'Show section entry'
  t['permissions.edit']   = 'Edit section entry'
  t['permissions.new']    = 'Add section entry'
  t['permissions.delete'] = 'Delete section entry'
end
