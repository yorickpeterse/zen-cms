# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'menus'

  trans.translate do |t|
    t['titles.index'] = 'Menu\'s'
    t['titles.edit']  = 'Menu aanpassen'
    t['titles.new']   = 'Menu aanmaken'

    t['labels.id']           = '#'
    t['labels.name']         = 'Naam'
    t['labels.slug']         = 'Slug'
    t['labels.description']  = 'Beschrijving'
    t['labels.html_class']   = 'HTML klasse'
    t['labels.html_id']      = 'HTML ID'
    t['labels.manage_items'] = 'Menu items beheren'

    t['descriptions.name'] = 'De naam van het menu.'
    t['descriptions.slug'] = 'Een URL vriendelijke versie van de ' \
      'menu naam.'
    t['descriptions.html_class'] = 'Een of meerdere klasses voor dit menu.'
    t['descriptions.html_id']    = 'Een ID voor dit menu.'

    t['messages.no_menus'] = 'Er zijn geen menu\'s gevonden.'

    t['buttons.new']    = 'Menu toevoegen'
    t['buttons.save']   = 'Menu opslaan'
    t['buttons.delete'] = 'Geselecteerde menu\'s verwijderen'

    t['success.new']    = 'Het menu is aangemaakt.'
    t['success.save']   = 'Het menu is aangepast.'
    t['success.delete'] = 'De geselecteerde menu\'s zijn verwijderd.'

    t['errors.new']       = 'Het menu kon niet worden aangemaakt.'
    t['errors.save']      = 'Het menu kon niet worden aangepast.'
    t['errors.delete']    = 'Het menu met ID #%s kon niet worden verwijderd.'
    t['errors.no_delete'] = 'U moet ten minste 1 menu specificeren ' \
      'om te verwijderen.'
    t['errors.invalid_menu'] = 'Het opgegeven menu is ongeldig.'

    t['description'] = 'Beheren van menu\'s en menu items.'

    t['permissions.show']   = 'Menu weergeven'
    t['permissions.edit']   = 'Menu aanpassen'
    t['permissions.new']    = 'Menu toevoegen'
    t['permissions.delete'] = 'Menu verwijderen'
  end
end
