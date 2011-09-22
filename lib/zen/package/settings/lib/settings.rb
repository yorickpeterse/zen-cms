Zen::Package.add do |p|
  p.name       = :settings
  p.title      = 'settings.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://yorickpeterse.com/'
  p.about      = 'settings.description'
  p.root       = __DIR__('settings')
  p.migrations = __DIR__('../migrations')

  p.menu(
    'settings.titles.index',
    '/admin/settings',
    :permission => :show_setting
  )

  p.permission :show_setting, 'settings.permissions.show'
  p.permission :edit_setting, 'settings.permissions.edit'
end

Zen::Language.load('settings')

require __DIR__('settings/model/setting')
require __DIR__('settings/controller/settings')
require __DIR__('settings/plugin/settings')

# Register the plugin
Zen::Plugin.add do |plugin|
  plugin.name   = 'settings'
  plugin.author = 'Yorick Peterse'
  plugin.url    = 'http://yorickpeterse.com/'
  plugin.about  = 'settings.plugin_description'
  plugin.plugin = Settings::Plugin::Settings
end

# Register all setting groups
plugin(:settings, :register_group) do |group|
  group.title = 'settings.tabs.general'
  group.name  = 'general'
end

plugin(:settings, :register_group) do |group|
  group.title = 'settings.tabs.security'
  group.name  = 'security'
end

# Register all settings
plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.website_name')
  setting.description = lang('settings.placeholders.website_name')
  setting.name        = 'website_name'
  setting.group       = 'general'
  setting.default     = 'Zen'
  setting.type        = 'textbox'
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.website_description')
  setting.description = lang('settings.placeholders.website_description')
  setting.name        = 'website_description'
  setting.group       = 'general'
  setting.type        = 'textarea'
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.language')
  setting.description = lang('settings.placeholders.language')
  setting.name        = 'language'
  setting.group       = 'general'
  setting.default     = 'en'
  setting.type        = 'select'
  setting.values      = Zen::Language::Languages
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.frontend_language')
  setting.description = lang('settings.placeholders.frontend_language')
  setting.name        = 'frontend_language'
  setting.group       = 'general'
  setting.default     = 'en'
  setting.type        = 'select'
  setting.values      = Zen::Language::Languages
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.theme')
  setting.description = lang('settings.placeholders.theme')
  setting.name        = 'theme'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = lambda do
    theme_hash = {}

    Zen::Theme::Registered.each do |name, theme|
      name             = name.to_s
      theme_hash[name] = name
    end

    return theme_hash
  end
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.date_format')
  setting.description = lang('settings.placeholders.date_format')
  setting.name        = 'date_format'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.default     = '%Y-%m-%d %H:%M:%S'
  setting.values      = {
    '%Y-%m-%d %H:%M:%S' => '2011-05-10 13:30:12',
    '%d-%m-%Y %H:%M:%S' => '10-05-2011 13:30:12',
    '%A, %B %d, %Y'     => 'Tuesday, May 10, 2011'
  }
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.enable_antispam')
  setting.description = lang('settings.placeholders.enable_antispam')
  setting.name        = 'enable_antispam'
  setting.group       = 'security'
  setting.type        = 'radio'
  setting.values      = {
    lang('zen_general.special.boolean_hash.true')  => '1',
    lang('zen_general.special.boolean_hash.false') => '0'
  }
end
