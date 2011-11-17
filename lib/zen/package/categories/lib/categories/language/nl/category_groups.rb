# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'category_groups'

  trans.translate do |t|
    t['titles.index'] = 'Categorie groepen'
    t['titles.edit']  = 'Categorie groep aanpassen'
    t['titles.new']   = 'Categorie groep aanmaken'

    t['labels.id']          = '#'
    t['labels.name']        = 'Naam'
    t['labels.description'] = 'Beschrijving'
    t['labels.manage']      = 'Categoriën beheren'

    t['description.name']   = 'De naam van de group'
    t['messages.no_groups'] = 'Er konden geen groepen worden gevonden.'

    t['success.new']    = 'De categorie groep is aangemaakt.'
    t['success.save']   = 'De categorie groep is aangepast.'
    t['success.delete'] = 'De categorie groep is verwijderd.'

    t['errors.new']    = 'De categorie groep kon niet worden aangemaakt.'
    t['errors.save']   = 'De categorie groep kon niet worden aangepast.'
    t['errors.delete'] = 'De categorie groep met ID #%s kon niet worden ' \
      'verwijderd.'
    t['errors.invalid_group'] = 'De opgegeven categorie groep is ongeldig.'
    t['errors.no_delete']     = 'U moet een groep opgeven om te verwijderen.'

    t['buttons.new']    = 'Groep aanmaken'
    t['buttons.save']   = 'Groep opslaan'
    t['buttons.delete'] = 'Geselecteerde groepen verwijderen'

    t['permissions.show']   = 'Categorie groep weergeven'
    t['permissions.edit']   = 'Categorie groep aanpassen'
    t['permissions.new']    = 'Categorie groep aanmaken'
    t['permissions.delete'] = 'Categorie groep verwijderen'

    t['description'] = 'Beheren van categorie groepen en categoriën.'
  end
end
