
require __DIR__ 'settings/model/setting'
require __DIR__ 'settings/controller/settings'
require __DIR__ 'settings/liquid/setting'

Liquid::Template.register_tag('setting', Settings::Liquid::Setting)

Zen::Extension.add do |ext|
  ext.name        = 'Settings'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = 'Module for managing settings such as the default module, whether or not to allow registration, etc.'
  ext.identifier  = 'com.yorickpeterse.settings'
  ext.directory   = __DIR__('settings')
  
  ext.menu = [{
    :title => "Settings",
    :url   => "admin/settings"
  }] 
end
