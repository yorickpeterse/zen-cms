Settings::SettingsGroup.add do |group|
  group.title = 'users.tabs.settings'
  group.name  = :users
end

Settings::Setting.add do |setting|
  setting.title       = 'users.labels.allow_registration'
  setting.description = 'users.descriptions.allow_registration'
  setting.name        = :allow_registration
  setting.group       = :users
  setting.default     = '0'
  setting.type        = 'radio'
  setting.values      = lambda do
    return {
      lang('zen_general.special.boolean_hash.true')  => '1',
      lang('zen_general.special.boolean_hash.false') => '0'
    }
  end
end
