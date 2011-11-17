# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'section_entries'

  t['titles.index'] = 'Sectie items'
  t['titles.edit']  = 'Sectie item aanpassen'
  t['titles.new']   = 'Sectie item aanmaken'

  t['labels.id']         = '#'
  t['labels.title']      = 'Titel'
  t['labels.slug']       = 'Slug'
  t['labels.status']     = 'Status'
  t['labels.created_at'] = 'Aanmaak datum'
  t['labels.updated_at'] = 'Aanpas datum'
  t['labels.author']     = 'Auteur'

  t['special.status_hash.draft']     = 'Voorbeeld'
  t['special.status_hash.published'] = 'Gepubliceerd'

  t['tabs.basic']      = 'Algemeen'
  t['tabs.categories'] = 'Categoriën'

  t['messages.no_entries']    = 'Er konden geen items worden gevonden.'
  t['messages.no_categories'] = 'De huidige sectie bevat geen categoriën.'

  t['success.new']    = 'Het sectie item is aangemaakt.'
  t['success.save']   = 'Het sectie item is aangepast.'
  t['success.delete'] = 'Alle geselecteerde items zijn verwijderd.'

  t['errors.new']        = 'Het sectie item kon niet worden aangemaakt.'
  t['errors.save']       = 'Het sectie item kon niet worden aangepast.'
  t['errors.delete']     = 'Het sectie item met ID #%s kon niet ' \
    'worden verwijderd.'
  t['errors.no_delete']  = 'U moet ten minste 1 item specificeren ' \
    'om te verwijderen.'
  t['errors.invalid_entry'] = 'Het opgegeven item is ongeldig.'

  t['buttons.new']    = 'Sectie item toevoegen'
  t['buttons.save']   = 'Sectie item opslaan'
  t['buttons.delete'] = 'Geselecteerde items verwijderen'

  t['permissions.show']   = 'Sectie item weergeven'
  t['permissions.edit']   = 'Sectie item aanpassen'
  t['permissions.new']    = 'Sectie item aanmaken'
  t['permissions.delete'] = 'Sectie item verwijderen'
end
