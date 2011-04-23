require __DIR__('categories/model/category_group')
require __DIR__('categories/model/category')
require __DIR__('categories/controller/category_groups')
require __DIR__('categories/controller/categories')
require __DIR__('categories/plugin/categories')

# Describe what this package is all about
Zen::Package.add do |p|
  p.name          = 'categories'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Module for managing categories. Categories can be used to organize 
section entries."

  p.directory     = __DIR__('categories')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Categories",
    :url   => "admin/category-groups"
  }]

  # Register all controllers
  p.controllers = [
    Categories::Controller::CategoryGroups, Categories::Controller::Categories
  ]
end

# Register our plugins
Zen::Plugin.add do |p|
  p.name   = 'categories'
  p.author = 'Yorick Peterse'
  p.url    = 'http://yorickpeterse.com/'
  p.about  = 'Plugin that makes it easier to retrieve categories and category groups.'
  p.plugin = Categories::Plugin::Categories
end
