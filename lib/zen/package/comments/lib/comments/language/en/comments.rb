Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'comments'

  t['titles.index'] = 'Comments'
  t['titles.edit']  = 'Edit Comment'

  t['labels.id']               = '#'
  t['labels.website']          = 'Website'
  t['labels.entry']            = 'Section Entry'
  t['labels.email']            = 'Email'
  t['labels.status']           = 'Status'
  t['labels.comment']          = 'Comment'
  t['labels.name']             = 'Name'
  t['labels.created_at']       = 'Created'
  t['labels.updated_at']       = 'Updated'
  t['labels.defensio']         = 'Defensio'
  t['labels.anti_spam_system'] = 'Anti-spam System'
  t['labels.open']             = 'Open'
  t['labels.closed']           = 'Closed'
  t['labels.spam']             = 'Spam'
  t['labels.defensio_key']     = 'Defensio Key'

  t['messages.no_comments'] = 'No comments were found.'

  t['descriptions.anti_spam_system'] = 'The anti-spam system to use for ' \
    'validating comments.'
  t['description.defensio_key'] = 'The API key for the Defensio anti-spam ' \
    'system.'

  t['succes.new']       = 'The comment has been created.'
  t['succes.save']      = 'The comment has been modified.'
  t['success.delete']   = 'The selected comments have been deleted.'
  t['success.moderate'] = 'The comment has been posted but must be approved ' \
    'by a moderator before it will be displayed.'

  t['errors.new']                  = 'Failed to create the new comment.'
  t['errors.save']                 = 'Failed to modify the comment.'
  t['errors.delete']               = 'Failed to delete the comment with ID #%s.'
  t['errors.no_delete']            = 'You need to specify a comment to delete.'
  t['errors.invalid_entry']        = 'The specified section entry is invalid.'
  t['errors.comments_not_allowed'] = 'Comments are not allowed for this section.'
  t['errors.comments_require_account'] = 'You have to be logged in in order ' \
    'to post a comment.'
  t['errors.invalid_comment'] = 'The specified comment is invalid.'

  t['buttons.delete'] = 'Delete selected comments'
  t['buttons.save']   = 'Save comment'

  t['permissions.show']   = 'Show comment'
  t['permissions.edit']   = 'Edit comment'
  t['permissions.delete'] = 'Delete comment'

  t['description'] = 'Manage comments'
end
