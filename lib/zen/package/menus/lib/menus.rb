Zen::Package.add do |p|
  p.name       = :menus
  p.title      = 'menus.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'menus.description'
  p.root       = __DIR__('menus')
  p.migrations = __DIR__('../migrations')

  p.menu 'menus.titles.index', '/admin/menus', :permission => :show_menu

  p.permission :show_menu  , 'menus.permissions.show'
  p.permission :edit_menu  , 'menus.permissions.edit'
  p.permission :new_menu   , 'menus.permissions.new'
  p.permission :delete_menu, 'menus.permissions.delete'

  p.permission :show_menu_item  , 'menu_items.permissions.show'
  p.permission :edit_menu_item  , 'menu_items.permissions.edit'
  p.permission :new_menu_item   , 'menu_items.permissions.new'
  p.permission :delete_menu_item, 'menu_items.permissions.delete'
end

require __DIR__('menus/model/menu')
require __DIR__('menus/model/menu_item')
require __DIR__('menus/controller/menus')
require __DIR__('menus/controller/menu_items')

Zen::Controller::FrontendController.helper(:menu_frontend)

Zen::Event.listen :post_start do
  Zen::Language.load('menus')
  Zen::Language.load('menu_items')
end
