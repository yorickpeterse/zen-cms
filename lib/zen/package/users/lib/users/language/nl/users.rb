# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'users'

  trans.translate do |t|
    t['titles.index']    = 'Gebruikers'
    t['titles.edit']     = 'Gebruiker aanpassen'
    t['titles.new']      = 'Gebruiker aanmaken'
    t['titles.login']    = 'Inloggen'
    t['titles.register'] = 'Registreren'

    t['labels.id']                 = '#'
    t['labels.email']              = 'Email'
    t['labels.name']               = 'Naam'
    t['labels.website']            = 'Website'
    t['labels.password']           = 'Wachtwoord'
    t['labels.confirm_password']   = 'Bevestig wachtwoord'
    t['labels.status']             = 'Status'
    t['labels.created_at']         = 'Aanmaak datum'
    t['labels.updated_at']         = 'Aanpas datum'
    t['labels.last_login']         = 'Login datum'
    t['labels.user_groups']        = 'Gebruikers groepen'
    t['labels.language']           = 'Taal'
    t['labels.frontend_language']  = 'Bezoekers taal'
    t['labels.date_format']        = 'Datum formaat'
    t['labels.allow_registration'] = 'Registratie toegestaan'

    t['descriptions.date_format'] = 'Het formaat van de datums in het ' \
      'admin gedeelte.'
    t['descriptions.allow_registration'] = 'Sta niet geregistreerde gebruikers ' \
      'toe om een account te registreren.'

    t['special.status_hash.active'] = 'Actief'
    t['special.status_hash.closed'] = 'Gesloten'

    t['messages.no_users'] = 'Er zijn geen gebruikers gevonden.'

    t['success.new']     = 'De gebruiker is aangemaakt.'
    t['success.save']    = 'De gebruiker is aangepast.'
    t['success.delete']  = 'Alle gespecificeerde gebruikers zijn verwijderd.'
    t['success.login']   = 'U bent nu ingelogd.'
    t['success.logout']  = 'U bent nu uitgelogd.'
    t['success.success'] = 'De account is geregistreerd.'

    t['errors.new']       = 'De gebruiker kon niet worden aangemaakt.'
    t['errors.save']      = 'De gebruiker kon niet worden aangepast.'
    t['errors.delete']    = 'De gebruiker met ID #%s kon niet worden verwijderd.'
    t['errors.no_delete'] = 'U moet ten minste 1 gebruiker specificeren ' \
      'om te verwijderen.'
    t['errors.no_password_match'] = 'De opgegeven wachtwoorden komen niet overeen.'
    t['errors.login']   = 'U kon niet worden ingelogd.'
    t['errors.logout']  = 'U kon niet worden uitgelogd, misschien bent ' \
      'u al uitgelogd.'
    t['errors.invalid_user'] = 'De opgegeven gebruiker is ongeldig.'
    t['errors.register']     = 'De account kon niet worden geregistreerd.'

    t['buttons.login']    = 'Inloggen'
    t['buttons.new']      = 'Gebruiker toevoegen'
    t['buttons.save']     = 'Gebruiker opslaan'
    t['buttons.delete']   = 'Geselecteerde gebruikers verwijderen'
    t['buttons.register'] = 'Bevestig registratie'

    t['description'] = 'Beheer gebruikers, gebruikers groepen en rechten.'

    t['permissions.show']   = 'Rechten weergeven'
    t['permissions.edit']   = 'Rechten aanpassen'
    t['permissions.new']    = 'Rechten aanmaken'
    t['permissions.delete'] = 'Rechten verwijderen'
    t['permissions.status'] = 'Gebruikers status aanpassen'

    t['tabs.settings'] = 'Gebruikers instellingen'
  end
end
