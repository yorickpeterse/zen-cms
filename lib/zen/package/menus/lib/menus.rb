Ramaze::HelpersHelper.options.paths.push(__DIR__('menus'))

require __DIR__('menus/model/menu')
require __DIR__('menus/model/menu_item')
require __DIR__('menus/controller/menus')
require __DIR__('menus/controller/menu_items')
require __DIR__('menus/plugin/menus')

Zen::Package.add do |p|
  p.name          = 'menus' 
  p.author        = 'Yorick Peterse'
  p.url           = 'http://zen-cms.com/userguide/menus'
  p.about         = 'The Menus extension allows you to easily create navigation menus 
for the frontend.'

  p.directory     = __DIR__('menus')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title => "Menus",
    :url   => "/admin/menus"
  }]
end

Zen::Plugin.add do |p|
  p.name    = 'menus'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'Plugin that can be used to display a navigation menu.'
  p.plugin  = Menus::Plugin::Menus
end
