Zen::Package.add do |p|
  p.name       = :settings
  p.title      = 'settings.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'settings.description'
  p.root       = __DIR__('settings')
  p.migrations = __DIR__('../migrations')

  p.menu 'settings.titles.index',
    '/admin/settings',
    :permission => :show_setting

  p.permission :show_setting, 'settings.permissions.show'
  p.permission :edit_setting, 'settings.permissions.edit'
end

require __DIR__('settings/model/setting')
require __DIR__('settings/controller/settings')
require __DIR__('settings/settings_group')
require __DIR__('settings/setting')
require __DIR__('settings/singleton_methods')
require __DIR__('settings/blue_form_parameters')

# Load all the setting groups and settings.
require __DIR__('settings/setting_groups')
require __DIR__('settings/settings')

include Settings::SingletonMethods

Zen::Event.listen :post_start do
  Zen::Language.load('settings')

  begin
    Settings::Setting.migrate
  rescue => e
    Ramaze::Log.warn(
      'Failed to migrate the settings, make sure the database ' \
        'table is up to date and that you executed rake db:migrate.'
    )
  end
end
