# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'comments'

  trans.translate do |t|
    t['titles.index'] = 'Reacties'
    t['titles.edit']  = 'Reactie aanpassen'

    t['labels.id']               = '#'
    t['labels.website']          = 'Website'
    t['labels.entry']            = 'Sectie artikel'
    t['labels.email']            = 'Email'
    t['labels.stats']            = 'Status'
    t['labels.comment']          = 'Reactie'
    t['labels.name']             = 'Naam'
    t['labels.created_at']       = 'Aangemaakt'
    t['labels.updated_at']       = 'Aangepast'
    t['labels.defensio']         = 'Defensio'
    t['labels.anti_spam_system'] = 'Anti-spam systeem'
    t['labels.open']             = 'Open'
    t['labels.closed']           = 'Gesloten'
    t['labels.spam']             = 'Spam'
    t['labels.defensio_key']     = 'Defensio sleutel'

    t['messages.no_comments'] = 'Er konden geen reacties worden gevonden.'

    t['descriptions.anti_spam_system'] = 'Het anti-spam systeem dat gebruikt ' \
      'moet worden voor het verifiëren van reacties.'
    t['descriptions.defensio_key'] = 'De API sleutel voor het Defensio ' \
      'anti-spam systeem.'

    t['success.new']      = 'De reactie is aangemaakt.'
    t['success.save']     = 'De reactie is aangepast.'
    t['success.delete']   = 'De geselecteerde reacties zijn verwijderd.'
    t['success.moderate'] = 'De reactie is aangemaakt en zal worden ' \
      'weergegeven zodra deze is goedgekeurd.'

    t['errors.new']           = 'De reactie kon niet worden aangemaakt.'
    t['errors.save']          = 'De reactie kon niet worden aangepast.'
    t['errors.delete']        = 'De reactie met ID #%s kon niet worden verwijderd.'
    t['errors.no_delete']     = 'U moet een reactie opgeven om te verwijderen.'
    t['errors.invalid_entry'] = 'Het opgegeven artikel is ongeldig.'

    t['errors.comments_not_allowed'] = 'Reacties zijn niet toegestaan voor ' \
      'deze sectie.'
    t['errors.comments_require_account'] = 'U moet ingelogd zijn om een ' \
      'reactie te kunnen plaatsen.'
    t['errors.invalid_comment'] = 'De opgegeven reactie is ongeldig.'

    t['buttons.delete'] = 'Reacties verwijderen'
    t['buttons.save']   = 'Reactie opslaan'

    t['permissions.show']   = 'Reactie weergeven'
    t['permissions.edit']   = 'Reactie aanpassen'
    t['permissions.delete'] = 'Reactie verwijderen'

    t['description'] = 'Reacties beheren'
  end
end
