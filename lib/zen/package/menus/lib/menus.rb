Zen::Package.add do |p|
  p.name       = :menus
  p.title      = 'menus.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/userguide/menus'
  p.about      = 'menus.description'
  p.root       = __DIR__('menus')
  p.migrations = __DIR__('../migrations')

  p.menu('menus.titles.index', '/admin/menus', :permission => :show_menu)

  p.permission :show_menu  , 'menus.permissions.show'
  p.permission :edit_menu  , 'menus.permissions.edit'
  p.permission :new_menu   , 'menus.permissions.new'
  p.permission :delete_menu, 'menus.permissions.delete'

  p.permission :show_menu_item  , 'menu_items.permissions.show'
  p.permission :edit_menu_item  , 'menu_items.permissions.edit'
  p.permission :new_menu_item   , 'menu_items.permissions.new'
  p.permission :delete_menu_item, 'menu_items.permissions.delete'
end

Zen::Language.load('menus')
Zen::Language.load('menu_items')

require __DIR__('menus/model/menu')
require __DIR__('menus/model/menu_item')
require __DIR__('menus/controller/menus')
require __DIR__('menus/controller/menu_items')
require __DIR__('menus/plugin/menus')

Zen::Plugin.add do |p|
  p.name    = 'menus'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'menus.plugin_description'
  p.plugin  = Menus::Plugin::Menus
end
