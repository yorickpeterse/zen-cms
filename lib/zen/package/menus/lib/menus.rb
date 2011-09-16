root = __DIR__('menus')

Ramaze::HelpersHelper.options.paths.push(root)
Ramaze.options.roots.push(root)
Zen::Language.options.paths.push(root)

require __DIR__('menus/model/menu')
require __DIR__('menus/model/menu_item')
require __DIR__('menus/controller/menus')
require __DIR__('menus/controller/menu_items')
require __DIR__('menus/plugin/menus')

Zen::Language.load('menus')
Zen::Language.load('menu_items')

Zen::Package.add do |p|
  p.name          = 'menus'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://zen-cms.com/userguide/menus'
  p.about         = 'The Menus extension allows you to easily create ' \
    'navigation menus for the frontend.'

  p.directory     = __DIR__('menus')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title => lang('menus.titles.index'),
    :url   => '/admin/menus'
  }]

  p.controllers = {
    lang('menus.titles.index')      => Menus::Controller::Menus,
    lang('menu_items.titles.index') => Menus::Controller::MenuItems
  }
end

Zen::Plugin.add do |p|
  p.name    = 'menus'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'Plugin that can be used to display a navigation menu.'
  p.plugin  = Menus::Plugin::Menus
end
