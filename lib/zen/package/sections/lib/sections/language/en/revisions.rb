Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'revisions'

  trans.translate do |t|
    t['titles.index']         = 'Revisions'
    t['titles.differences']   = 'Differences'
    t['titles.revisions_for'] = 'Revisions for %s'

    t['labels.old']        = 'Old'
    t['labels.new']        = 'New'
    t['labels.id']         = '#'
    t['labels.user']       = 'User'
    t['labels.created_at'] = 'Created at'
    t['labels.restore']    = 'Restore'
    t['labels.maximum']    = 'Revision amount'

    t['descriptions.maximum'] = 'The maximum amount of revisions to keep.'

    t['buttons.compare'] = 'Compare'

    t['messages.no_differences'] = 'There are no differences between the ' \
      'two specified revisions.'

    t['messages.no_revisions'] = 'There are no revisions for this entry.'

    t['success.restore'] = 'The revision has been restored'
    t['errors.restore']  = 'The revision could not be restored'
    t['errors.invalid']  = 'The specified revision is invalid'

    t['permissions.show']    = 'Show revision'
    t['permissions.restore'] = 'Restore revision'
  end
end
