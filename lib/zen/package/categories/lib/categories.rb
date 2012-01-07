Zen::Package.add do |p|
  p.name       = :categories
  p.title      = 'categories.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'category_groups.description'
  p.root       = __DIR__('categories')
  p.migrations = __DIR__('../migrations')

  p.menu 'categories.titles.index',
    '/admin/category-groups',
    :permission => :show_category_group

  p.permission :show_category_group  , 'category_groups.permissions.show'
  p.permission :edit_category_group  , 'category_groups.permissions.edit'
  p.permission :new_category_group   , 'category_groups.permissions.new'
  p.permission :delete_category_group, 'category_groups.permissions.delete'

  p.permission :show_category  , 'categories.permissions.show'
  p.permission :edit_category  , 'categories.permissions.edit'
  p.permission :new_category   , 'categories.permissions.new'
  p.permission :delete_category, 'categories.permissions.delete'
end

require __DIR__('categories/model/category_group')
require __DIR__('categories/model/category')
require __DIR__('categories/controller/category_groups')
require __DIR__('categories/controller/categories')

Zen::Controller::FrontendController.helper(:category_frontend)

Zen::Event.listen :post_start do
  Zen::Language.load('categories')
  Zen::Language.load('category_groups')
end
