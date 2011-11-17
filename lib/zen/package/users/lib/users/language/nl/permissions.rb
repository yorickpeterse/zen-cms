# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'nl'
  trans.name     = 'permissions'

  trans.translate do |t|
    t['titles.index'] = 'Rechten'

    t['permissions.show'] = 'Rechten weergeven'
    t['permissions.edit'] = 'Rechten aanpassen'

    t['buttons.allow_all'] = 'Sta alles toe'
    t['buttons.deny_all']  = 'Sta niks toe'
  end
end
