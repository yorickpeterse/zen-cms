Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'revisions'

  trans.translate do |t|
    t['titles.index']         = 'Revisies'
    t['titles.differences']   = 'Verschillen'
    t['titles.revisions_for'] = 'Revisies voor %s'

    t['labels.old']        = 'Oud'
    t['labels.new']        = 'Nieuw'
    t['labels.id']         = '#'
    t['labels.user']       = 'Gebruiker'
    t['labels.created_at'] = 'Aangemaak datum'
    t['labels.restore']    = 'Herstel'
    t['labels.maximum']    = 'Aantal revisies'

    t['descriptions.maximum'] = 'Het maximale aantal revisies dat behouden ' \
      'moet blijven.'

    t['buttons.compare'] = 'Vergelijk'

    t['messages.no_differences'] = 'Er zijn geen verschillen tussen de twee ' \
      'geselecteerde revisies.'

    t['messages.no_revisions'] = 'Er zijn geen revisies voor dit item.'

    t['success.restore'] = 'De revisie is hersteld'
    t['errors.restore']  = 'De revisie kon niet worden hersteld'
    t['errors.invalid']  = 'De opgegeven revisie is ongeldig'

    t['permissions.show']    = 'Revisie weergeven'
    t['permissions.restore'] = 'Revisie herstellen'
  end
end
