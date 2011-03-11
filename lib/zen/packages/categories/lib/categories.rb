
# Load all the classes such as controllers, models and so on.
require __DIR__ 'categories/model/category_group'
require __DIR__ 'categories/model/category'

require __DIR__ 'categories/controller/category_groups'
require __DIR__ 'categories/controller/categories'

# Describe what this package is all about
Zen::Package.add do |p|
  p.type        = 'extension'
  p.name        = 'Categories'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.version     = '1.0'
  p.about       = "Module for managing categories. Categories can be used to organize section entries."
  p.identifier  = 'com.zen.categories'
  p.directory   = __DIR__('categories')
  
  p.menu = [{
    :title => "Categories",
    :url   => "admin/category_groups"
  }]
end
