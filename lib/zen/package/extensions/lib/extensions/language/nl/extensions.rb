# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'extensions'

  trans.translate do |t|
    t['titles.index']     = 'Extensies'
    t['permissions.show'] = 'Extensie weergeven'

    t['labels.packages']            = 'Pakketten'
    t['labels.themes']              = 'Thema\'s'
    t['labels.languages']           = 'Talen'
    t['labels.package']             = 'Pakket'
    t['labels.author']              = 'Auteur'
    t['labels.description']         = 'Beschrijving'
    t['labels.theme']               = 'Thema'
    t['labels.language']            = 'Taal'
    t['labels.rtl']                 = 'Rechts naar links'
    t['labels.loaded_translations'] = 'Aantal ingeladen vertalingen'

    t['description'] = 'Laat alle geïnstalleerde extensies zien zoals ' \
      'pakketten en taal bestanden.'
  end
end
