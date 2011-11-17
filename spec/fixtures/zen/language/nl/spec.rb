Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'spec'

  trans.translate do |t|
    t['name'] = 'Naam'
    t['age']  = 'Leeftijd'

    t['parent.sub'] = 'Sub element'
  end
end
