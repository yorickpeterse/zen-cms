# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'categories'

  t['titles.index'] = 'Categoriën'
  t['titles.edit']  = 'Categorie aanpassen'
  t['titles.new']   = 'Categorie aanmaken'

  t['labels.id']          = '#'
  t['labels.name']        = 'Naam'
  t['labels.description'] = 'Beschrijving'
  t['labels.parent']      = 'Ouder'
  t['labels.slug']        = 'Slug'

  t['descriptions.name'] = 'De naam van de categorie'
  t['descriptions.slug'] = 'Een URL vriendelijke versie van de naam'

  t['messages.no_categories'] = 'Er konden geen categoriën worden gevonden'

  t['success.new']    = 'De categorie is aangemaakt.'
  t['success.save']   = 'De categorie is aangepast.'
  t['success.delete'] = 'De categorie is verwijderd.'

  t['errors.new']       = 'De categorie kon niet worden aangemaakt.'
  t['errors.save']      = 'De categorie kon niet worden aangepast.'
  t['errors.delete']    = 'De categorie met ID #%s kon niet worden verwijderd.'
  t['errors.no_delete']        = 'U moet ten minste 1 categorie specificeren.'
  t['errors.invalid_category'] = 'De opgegeven categorie is ongeldig.'

  t['buttons.new']    = 'Categorie aanmaken'
  t['buttons.save']   = 'Categorie opslaan'
  t['buttons.delete'] = 'Geselecteerde categoriën verwijderen'

  t['permissions.show']   = 'Categorie weergeven'
  t['permissions.edit']   = 'Categorie aanpassen'
  t['permissions.new']    = 'Categorie aanmaken'
  t['permissions.delete'] = 'Categorie verwijderen'
end
