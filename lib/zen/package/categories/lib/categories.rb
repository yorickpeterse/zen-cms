
# Load all the classes such as controllers, models and so on.
require __DIR__('categories/model/category_group')
require __DIR__('categories/model/category')

require __DIR__('categories/controller/category_groups')
require __DIR__('categories/controller/categories')

require __DIR__('categories/plugin/categories')

# Describe what this package is all about
Zen::Package.add do |p|
  p.name          = 'Categories'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Module for managing categories. Categories can be used to organize section entries."
  p.identifier    = 'com.zen.categories'
  p.directory     = __DIR__('categories')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Categories",
    :url   => "admin/category-groups"
  }]
end

# Register our plugins
Zen::Plugin.add do |p|
  p.name       = 'Categories'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://yorickpeterse.com/'
  p.about      = 'Plugin that makes it easier to retrieve categories and category groups.'
  p.identifier = 'com.zen.plugin.categories'
  p.plugin     = Categories::Plugin::Categories
end
