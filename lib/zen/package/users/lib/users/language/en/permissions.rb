# encoding: utf-8

Zen::Language::Translation.add do |trans|
  trans.language = 'en'
  trans.name     = 'permissions'

  trans.translate do |t|
    t['titles.index'] = 'Permissions'

    t['permissions.show'] = 'Show permissions'
    t['permissions.edit'] = 'Edit permissions'

    t['buttons.allow_all'] = 'Allow all'
    t['buttons.deny_all']  = 'Deny all'
  end
end
