Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'extensions'

  trans.translate do |t|
    t['titles.index']     = 'Extensions'
    t['permissions.show'] = 'Show extension'

    t['labels.packages']            = 'Packages'
    t['labels.themes']              = 'Themes'
    t['labels.languages']           = 'Languages'
    t['labels.package']             = 'Package'
    t['labels.author']              = 'Author'
    t['labels.description']         = 'Description'
    t['labels.theme']               = 'Theme'
    t['labels.language']            = 'Language'
    t['labels.rtl']                 = 'Right To Left'
    t['labels.loaded_translations'] = 'Loaded Translations'

    t['description'] = 'Shows all installed extensions such as packages and ' \
      'language files.'
  end
end
