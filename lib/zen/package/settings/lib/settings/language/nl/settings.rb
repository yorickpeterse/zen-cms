# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'settings'

  trans.translate do |t|
    t['titles.index'] = 'Instellingen'

    t['labels.website_name']        = 'Website naam'
    t['labels.website_description'] = 'Website beschrijving'
    t['labels.language']            = 'Taal'
    t['labels.frontend_langauge']   = 'Taal voor bezoekers'
    t['labels.default_section']     = 'Standaard sectie'
    t['labels.theme']               = 'Thema'
    t['labels.enable_antispam']     = 'Anti-spam inschakelen'
    t['labels.date_format']         = 'Datum formaat'

    t['descriptions.website_name']        = 'De naam van de website.'
    t['descriptions.website_description'] = 'De beschrijving van de website.'
    t['descriptions.language']            = 'De taal die gebruikt moet worden '\
      'voor het admin gedeelte.'
    t['descriptions.default_section'] = 'De standaard sectie die moet worden ' \
      'gebruikt.'
    t['descriptions.theme']           = 'Het thema dat bezoekers zullen zien.'
    t['descriptions.enable_antispam'] = 'Waarde die aangeeft of het anti-spam ' \
      'systeem moet worden gebruikt voor reacties.'
    t['descriptions.frontend_language'] = 'De taal die gebruikt moet worden '\
      'voor bezoekers.'
    t['descriptions.date_format'] = 'Het formaat van de datum voor het '\
      'admin gedeelte.'

    t['tabs.general']  = 'Algemeen'
    t['tabs.security'] = 'Beveiliging'

    t['buttons.save'] = 'Opslaan'
    t['success.save'] = 'De instellingen zijn opgeslagen.'
    t['errors.save']  = 'De instellingen konden niet worden opgeslagen.'
    t['description']  = 'Pakket voor het beheren van instellingen.'

    t['permissions.show'] = 'Instelling weergeven'
    t['permissions.edit'] = 'Instelling aanpassen'
  end
end
