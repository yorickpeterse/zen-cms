# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'user_groups'

  t['titles.index'] = 'Gebruikers groepen'
  t['titles.edit']  = 'Gebruikers groep aanpassen'
  t['titles.new']   = 'Gebruikers groep aanmaken'

  t['labels.id']          = '#'
  t['labels.name']        = 'Naam'
  t['labels.slug']        = 'Slug'
  t['labels.description'] = 'Beschrijving'
  t['labels.super_group'] = 'Beheerders groep'

  t['messages.no_groups'] = 'Er zijn geen gebruikers groepen gevonden.'

  t['success.new']    = 'De gebruikers groep is aangemaakt.'
  t['success.save']   = 'De gebruikers groep is aangepast.'
  t['success.delete'] = 'De geselecteerde groepen zijn verwijderd.'

  t['errors.new']    = 'De gebruikers groep kon niet worden aangemaakt.'
  t['errors.save']   = 'De gebruikers groep kon niet worden aangepast.'
  t['errors.delete'] = 'De gebruikers groep met ID #%s kon niet ' \
    'worden verwijderd.'
  t['errors.no_delete'] = 'U moet ten minste 1 groep specificeren ' \
    'om te verwijderen.'
  t['errors.invalid_group'] = 'De opgegeven gebruikers groep is ongeldig.'

  t['buttons.new']    = 'Groep toevoegen'
  t['buttons.delete'] = 'Geselecteerde groepen verwijderen'
  t['buttons.save']   = 'Groep opslaan'

  t['permissions.show']   = 'Groep weergeven'
  t['permissions.edit']   = 'Groep aanpassen'
  t['permissions.new']    = 'Groep aanmaken'
  t['permissions.delete'] = 'Groep verwijderen'
end
