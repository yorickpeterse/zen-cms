require __DIR__('settings/model/setting')
require __DIR__('settings/controller/settings')
require __DIR__('settings/plugin/settings')

Zen::Language.options.paths.push(__DIR__('settings'))
Zen::Language.load('settings')

# Register the package
Zen::Package.add do |p|
  p.name          = 'settings'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = 'Module for managing settings such as the default module, whether or 
not to allow registration, etc.'

  p.directory     = __DIR__('settings')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => lang('settings.titles.index'),
    :url   => 'admin/settings'
  }] 

  p.controllers = {
    lang('settings.titles.index') => Settings::Controller::Settings
  }
end

# Create all variables required for the settings
section_hash = {}
theme_hash   = {}

begin
  Sections::Model::Section.select(:name, :slug).each do |s|
    section_hash[s.slug] = s.name
  end
rescue => e
  Ramaze::Log.warn("The settings plugin failed to retrieve all sections: #{e.message}")
end

Zen::Theme::Registered.each do |ident, theme|
  theme_hash[ident] = theme.name
end

# ------

# Register the plugin
Zen::Plugin.add do |plugin|
  plugin.name       = 'settings'
  plugin.author     = 'Yorick Peterse'
  plugin.url        = 'http://yorickpeterse.com/'
  plugin.about      = 'Plugin that can be used to register, retrieve and migrate settings.'
  plugin.plugin     = Settings::Plugin::Settings
end

# Register all setting groups
plugin(:settings, :register_group) do |group|
  group.title = 'General'
  group.name  = 'general'
end

plugin(:settings, :register_group) do |group|
  group.title = 'Security'
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
  setting.title       = lang('settings.labels.website_enabled')
  setting.description = lang('settings.placeholders.website_enabled')
  setting.name        = 'website_enabled'
  setting.group       = 'general'
  setting.type        = 'radio'
  setting.default     = '1'
  setting.values      = {
    lang('zen_general.special.boolean_hash.true')  => '1',
    lang('zen_general.special.boolean_hash.false') => '0'
  }
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.language')
  setting.description = lang('settings.placeholders.language')
  setting.name        = 'language'
  setting.group       = 'general'
  setting.default     = 'en'
  setting.type        = 'select'
  setting.values      = {
    'en' => lang('zen_general.special.language_hash.en')
  }
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.default_section')
  setting.description = lang('settings.placeholders.default_section')
  setting.name        = 'default_section'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = section_hash
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.theme')
  setting.description = lang('settings.placeholders.theme')
  setting.name        = 'theme'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = theme_hash
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

plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.defensio_key')
  setting.description = lang('settings.placeholders.defensio_key')
  setting.name        = 'defensio_key'
  setting.group       = 'security'
  setting.type        = 'textbox'
end

# Migrate all settings
begin
  plugin(:settings, :migrate)
rescue
  Ramaze::Log.warn(
    "Failed to migrate the current settings, make sure the database table is up to date."
  )
end
