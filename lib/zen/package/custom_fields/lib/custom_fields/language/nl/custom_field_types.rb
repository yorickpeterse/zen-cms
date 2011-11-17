# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'custom_field_types'

  t['titles.index'] = 'Veld types'
  t['titles.edit']  = 'Veld type aanpassen'
  t['titles.new']   = 'Veld type toevoegen'

  t['labels.id']                     = '#'
  t['labels.name']                   = 'Naam'
  t['labels.language_string']        = 'Vertaal naam'
  t['labels.html_class']             = 'CSS klasse'
  t['labels.serialize']              = 'Serialiseren'
  t['labels.allow_markup']           = 'Opmaak toegestaan'
  t['labels.custom_field_method_id'] = 'Veld methode'

  t['descriptions.language_string'] = 'De volledige naam van de vertaling ' \
    'voor dit veld.'
  t['descriptions.html_class'] = 'Een set aan HTML klasses voor alle ' \
    'velden van dit type.'
  t['descriptions.serialize']    = 'De waarde wel of niet serialiseren.'
  t['descriptions.allow_markup'] = 'Opmaak toegestaan of niet.'

  t['messages.no_field_types'] = 'Er konden geen veld types worden gevonden.'

  t['errors.new']       = 'Het veld type kon niet worden aangemaakt.'
  t['errors.save']      = 'Het veld type kon niet worden aangepast.'
  t['errors.delete']    = 'Het veld type met ID #%s kon niet worden verwijderd.'
  t['errors.no_delete'] = 'U moet ten minste 1 veld type specificeren ' \
    'om te verwijderen.'
  t['errors.invalid_type'] = 'Het opgegeven veld type is ongeldig.'

  t['success.new']    = 'Het veld type is aangemaakt.'
  t['success.save']   = 'Het veld type is aangepast.'
  t['success.delete'] = 'Alle geselecteerde veld types zijn verwijderd.'

  t['buttons.new']    = 'Veld type toevoegen'
  t['buttons.delete'] = 'Geselecteerde types verwijderen'
  t['buttons.save']   = 'Veld type opslaan'

  t['permissions.show']   = 'Veld type weergeven'
  t['permissions.edit']   = 'Veld type aanpassen'
  t['permissions.new']    = 'Veld type aanmaken'
  t['permissions.delete'] = 'Veld type verwijderen'
end
