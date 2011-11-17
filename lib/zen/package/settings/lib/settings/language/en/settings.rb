# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'settings'

  trans.translate do |t|
    t['titles.index'] = 'Settings'

    t['labels.website_name']        = 'Website name'
    t['labels.website_description'] = 'Website description'
    t['labels.language']            = 'Language'
    t['labels.frontend_language']   = 'Frontend language'
    t['labels.default_section']     = 'Default section'
    t['labels.theme']               = 'Theme'
    t['labels.enable_antispam']     = 'Enable anti-spam'
    t['labels.date_format']         = 'Date format'

    t['descriptions.website_name']        = 'The name of the website.'
    t['descriptions.website_description'] = 'The description of the website.'
    t['descriptions.language']            = 'The language to use for the system.'
    t['descriptions.default_section']     = 'The default section to use on ' \
      'the homepage.'
    t['descriptions.theme']           = 'The frontend theme to use.'
    t['descriptions.enable_antispam'] = 'Whether or not anti-spam protection ' \
      'should be used for comments'
    t['descriptions.frontend_language'] = 'The language to use for the ' \
      'frontend of the website.'
    t['descriptions.date_format'] = 'A custom format used for all the dates ' \
      'displayed in the backend.'

    t['tabs.general']  = 'General'
    t['tabs.security'] = 'Security'

    t['buttons.save'] = 'Save'

    t['success.save'] = 'The settings have been saved.'
    t['errors.save']  = 'The settings could not be saved.'
    t['description']  = 'Package for managing settings.'

    t['permissions.show'] = 'Show setting'
    t['permissions.edit'] = 'Edit setting'
  end
end
