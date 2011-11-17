# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'nl'
  t.name     = 'menu_items'

  t['titles.index'] = 'Menu items'
  t['titles.edit']  = 'Menu item aanpassen'
  t['titles.new']   = 'Menu item aanmaken'

  t['labels.id']         = '#'
  t['labels.parent_id']  = 'Hoofd item'
  t['labels.name']       = 'Naam'
  t['labels.url']        = 'URL'
  t['labels.order']      = 'Volgorde'
  t['labels.html_class'] = 'HTML klasse'
  t['labels.html_id']    = 'HTML ID'

  t['descriptions.name']       = 'De naam/label van het menu item.'
  t['descriptions.url']        = 'De URL van het menu item.'
  t['descriptions.order']      = 'De sorteer volgorde.'
  t['descriptions.html_class'] = 'Een of meerdere klasses voor dit item.'
  t['descriptions.html_id']    = 'Een ID voor dit item.'

  t['messages.no_items'] = 'Er zijn geen menu items gevonden.'

  t['buttons.new']    = 'Menu item toevoegen'
  t['buttons.save']   = 'Menu item opslaan'
  t['buttons.delete'] = 'Geselecteerde menu items verwijderen'

  t['success.new']    = 'Het menu item is aangemaakt.'
  t['success.save']   = 'Het menu item is aangepast.'
  t['success.delete'] = 'De menu items zijn verwijderd.'

  t['errors.new']       = 'Het menu item kon niet worden aangemaakt.'
  t['errors.save']      = 'Het menu item kon niet worden aangepast.'
  t['errors.delete']    = 'Het menu item met ID #%s kon niet worden verwijderd.'
  t['errors.no_delete'] = 'U moet ten minste 1 item specificeren ' \
    'om te verwijderen.'
  t['errors.invalid_item'] = 'Het opgegeven menu item is ongeldig.'

  t['permissions.show']   = 'Menu item weergeven'
  t['permissions.edit']   = 'Menu item aanpassen'
  t['permissions.new']    = 'Menu item toevoegen'
  t['permissions.delete'] = 'Menu item verwijderen'
end
