# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'sections'

  trans.translate do |t|
    t['titles.index'] = 'Secties'
    t['titles.edit']  = 'Sectie aanpassen'
    t['titles.new']   = 'Sectie toevoegen'

    t['labels.id']                      = '#'
    t['labels.name']                    = 'Naam'
    t['labels.slug']                    = 'Slug'
    t['labels.description']             = 'Beschrijving'
    t['labels.comment_allow']           = 'Reacties toegestaan'
    t['labels.comment_require_account'] = 'Reacties vereisen een account'
    t['labels.comment_moderate']        = 'Beheer reacties'
    t['labels.comment_format']          = 'Text opmaak'
    t['labels.custom_field_groups']     = 'Veld groepen'
    t['labels.category_groups']         = 'Categorie groepen'
    t['labels.manage_entries']          = 'Beheer items'

    t['special.boolean_hash.true']  = 'Ja'
    t['special.boolean_hash.false'] = 'Nee'

    t['tabs.general']           = 'Algemeen'
    t['tabs.comment_settings']  = 'Reactie instellingen'
    t['tabs.group_assignments'] = 'Groepen'

    t['messages.no_sections'] = 'Er konden geen secties worden gevonden.'

    t['success.new']    = 'De sectie is aangemaakt.'
    t['success.save']   = 'De sectie is aangepast.'
    t['success.delete'] = 'Alle geselecteerde secties zijn verwijderd.'

    t['errors.new']       = 'De sectie kon niet worden aangemaakt.'
    t['errors.save']      = 'De sectie kon niet worden aangepast.'
    t['errors.delete']    = 'De sectie met ID #%s kon niet worden verwijderd.'
    t['errors.no_delete'] = 'U moet ten minste 1 sectie specificeren ' \
      'om te verwijderen.'
    t['errors.invalid_section'] = 'De opgegeven sectie is ongeldig.'

    t['buttons.new']    = 'Sectie toevoegen'
    t['buttons.save']   = 'Sectie opslaan'
    t['buttons.delete'] = 'Geselecteerde secties verwijderen'

    t['permissions.show']   = 'Sectie weergeven'
    t['permissions.edit']   = 'Sectie aanpassen'
    t['permissions.new']    = 'Sectie aanmaken'
    t['permissions.delete'] = 'Sectie verwijderen'

    t['description'] = 'Beheer secties en sectie items.'
  end
end
