Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'spec'

  trans.translate do |t|
    t['name'] = 'Name'
    t['age']  = 'Age'

    t['parent.sub'] = 'Sub item'
  end
end
