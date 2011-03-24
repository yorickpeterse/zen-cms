
require __DIR__ 'settings/model/setting'
require __DIR__ 'settings/controller/settings'
require __DIR__ 'settings/liquid/setting'

Liquid::Template.register_tag('setting', Settings::Liquid::Setting)

Zen::Package.add do |p|
  p.name        = 'Settings'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.about       = 'Module for managing settings such as the default module, whether or not to allow registration, etc.'
  p.identifier  = 'com.zen.settings'
  p.directory   = __DIR__('settings')
  
  p.menu = [{
    :title => "Settings",
    :url   => "admin/settings"
  }] 
end
