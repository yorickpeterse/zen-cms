# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'custom_fields'

  t['titles.index'] = 'Velden'
  t['titles.edit']  = 'Veld aanpassen'
  t['titles.new']   = 'Veld aanmaken'

  t['labels.id']                   = '#'
  t['labels.name']                 = 'Naam'
  t['labels.slug']                 = 'Slug'
  t['labels.format']               = 'Formaat'
  t['labels.description']          = 'Beschrijving'
  t['labels.possible_values']      = 'Mogelijke waardes (een per regel)'
  t['labels.required']             = 'Vereist een waarde'
  t['labels.text_editor']          = 'Text verwerker'
  t['labels.textarea_rows']        = 'Text veld rijen'
  t['labels.text_limit']           = 'Karakter limiet'
  t['labels.sort_order']           = 'Sorteer volgorde'
  t['labels.custom_field_type_id'] = 'Veld type'

  t['tabs.general']  = 'Algemeen'
  t['tabs.settings'] = 'Instellingen'

  t['messages.no_fields'] = 'Er konden geen velden worden gevonden.'

  t['success.new']    = 'Het veld is aangemaakt.'
  t['success.save']   = 'Het veld is aangepast.'
  t['success.delete'] = 'Alle geselecteerde velden zijn verwijderd.'

  t['errors.new']           = 'Het veld kon niet worden aangemaakt.'
  t['errors.save']          = 'Het veld kon niet worden aangepast.'
  t['errors.delete']        = 'Het veld met ID #%s kon niet worden verwijderd.'
  t['errors.invalid_field'] = 'Het opgegeven veld is ongeldig.'
  t['errors.no_delete']     = 'U moet ten minste 1 veld specificeren om ' \
    'te verwijderen.'

  t['special.type_hash.textbox']         = 'Text veld'
  t['special.type_hash.textarea']        = 'Text gebied'
  t['special.type_hash.radio']           = 'Keuze knop (enkele waarde)'
  t['special.type_hash.checkbox']        = 'Keuze knop (meerdere waardes)'
  t['special.type_hash.date']            = 'Datum'
  t['special.type_hash.select']          = 'Lijst (enkele waarde)'
  t['special.type_hash.select_multiple'] = 'Lijst (meerdere waardes)'
  t['special.type_hash.password']        = 'Wachtwoord'

  t['buttons.new']    = 'Veld toevoegen'
  t['buttons.delete'] = 'Geselecteerde velden verwijderen'
  t['buttons.save']   = 'Veld opslaan'

  t['permissions.show']   = 'Veld weergeven'
  t['permissions.edit']   = 'Veld aanpassen'
  t['permissions.new']    = 'Veld aanmaken'
  t['permissions.delete'] = 'Veld verwijderen'

  t['description'] = 'Beheer veld groepen, velden en veld types.'
end
