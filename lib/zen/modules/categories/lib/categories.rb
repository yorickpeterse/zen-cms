
# Load all the classes such as controllers, models and so on.
require __DIR__ 'categories/model/category_group'
require __DIR__ 'categories/model/category'

require __DIR__ 'categories/controller/category_groups'
require __DIR__ 'categories/controller/categories'

# Describe what this extension is all about
Zen::Extension.add do |ext|
  ext.name        = 'Categories'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = "Module for managing categories. Categories can be used to organize section entries."
  ext.identifier  = 'com.yorickpeterse.categories'
  ext.directory   = __DIR__('categories')
  
  ext.menu = [{
    :title => "Categories",
    :url   => "admin/category_groups"
  }]
end