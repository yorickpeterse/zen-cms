Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'zen_general'

  t['labels.powered_by']   = 'Aangedreven door'
  t['labels.view_website'] = 'Bekijk website'
  t['labels.logout']       = 'Log uit'
  t['labels.profile']      = 'Profiel'

  t['errors.csrf'] = 'De actie kon niet worden uitgevoerd zonder een geldige ' \
    'CSRF token.'

  t['errors.not_authorized'] = 'U bent niet toegestaan om de opgevraagde ' \
    'pagina te bekijken.'

  t['errors.no_templates'] = 'Er konden geen templates worden gevonden voor ' \
    'huidige actie.'

  t['errors.no_theme']        = 'Er is geen thema ingesteld.'
  t['errors.invalid_request'] = 'De actie kon niet worden uitgevoerd omdat ' \
    'de data onjuist is.'

  t['errors.require_login'] = 'U moet ingelogd zijn om de opgevraagde pagina ' \
    'te kunnen bekijken.'

  t['errors.invalid_search'] = 'De opgegeven zoek actie is ongeldig.'

  t['descriptions.search'] = 'Zoektermen'

  t['buttons.bold']    = 'Vet'
  t['buttons.italic']  = 'Cursief'
  t['buttons.link']    = 'Hyperlink'
  t['buttons.ul']      = 'Ongesorteerde lijst'
  t['buttons.ol']      = 'Gesorteerde lijst'
  t['buttons.preview'] = 'Voorbeeld'
  t['buttons.close']   = 'Sluiten'
  t['buttons.search']  = 'Zoeken'

  t['datepicker.select_a_time']   = 'Selecteer een tijd'
  t['datepicker.use_mouse_wheel'] = 'Gebruik het muis wiel om een waarde te ' \
    'selecteren'

  t['datepicker.time_confirm_button'] = 'Ok'
  t['datepicker.apply_range']         = 'Ok'
  t['datepicker.cancel']              = 'Annuleren'
  t['datepicker.week']                = 'W'

  t['special.boolean_hash.true']  = 'Ja'
  t['special.boolean_hash.false'] = 'Nee'

  t['markup.html']     = 'HTML'
  t['markup.markdown'] = 'Markdown'
  t['markup.textile']  = 'Textile'
  t['markup.plain']    = 'Platte tekst'
end
