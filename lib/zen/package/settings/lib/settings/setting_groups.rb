# Settings group for various settings that don't belong in any other group.
Settings::SettingsGroup.add do |group|
  group.title = 'settings.tabs.general'
  group.name  = 'general'
end

# Settings group for security related settings such as the Defensio API key.
Settings::SettingsGroup.add do |group|
  group.title = 'settings.tabs.security'
  group.name  = 'security'
end
