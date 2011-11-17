# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'custom_field_groups'

  t['titles.index'] = 'Veld groepen'
  t['titles.edit']  = 'Veld groep aanpassen'
  t['titles.new']   = 'Veld groep aanmaken'

  t['labels.id']            = '#'
  t['labels.name']          = 'Naam'
  t['labels.description']   = 'Beschrijving'
  t['labels.sections']      = 'Secties'
  t['labels.manage_fields'] = 'Beheer velden'
  t['labels.none']          = 'Geen'

  t['messages.no_groups'] = 'Er konden geen veld groepen worden aangemaakt.'

  t['success.new']    = 'De veld groep is aangemaakt.'
  t['success.save']   = 'De veld groep is aangepast.'
  t['success.delete'] = 'De veld groep is verwijderd.'

  t['errors.new']       = 'De veld groep kon niet worden aangemaakt.'
  t['errors.save']      = 'De veld groep kon niet worden aangepast.'
  t['errors.delete']    = 'De veld groep met ID #%s kon niet worden verwijderd.'
  t['errors.no_delete'] = 'U moet ten minste 1 groep specificeren om ' \
    'te verwijderen.'
  t['errors.invalid_group'] = 'De opgegeven veld groep is ongeldig.'

  t['buttons.new']    = 'Groep aanmaken'
  t['buttons.save']   = 'Groep opslaan'
  t['buttons.delete'] = 'Geselecteerde groepen verwijderen'

  t['permissions.show']   = 'Veld groep weergeven'
  t['permissions.edit']   = 'Veld groep aanpassen'
  t['permissions.new']    = 'Veld groep aanmaken'
  t['permissions.delete'] = 'Veld groep verwijderen'
end
