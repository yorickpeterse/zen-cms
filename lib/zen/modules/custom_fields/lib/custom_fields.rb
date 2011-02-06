
# Load all the classes such as controllers, models and so on.
require __DIR__ 'custom_fields/model/custom_field'
require __DIR__ 'custom_fields/model/custom_field_group'
require __DIR__ 'custom_fields/model/custom_field_value'

require __DIR__ 'custom_fields/controller/custom_field_groups'
require __DIR__ 'custom_fields/controller/custom_fields'

Zen::Extension.add do |ext|
  ext.name        = 'Custom Fields'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = "The Custom Fields module is used to manage, how original, custom fields and custom field groups."
  ext.identifier  = 'com.yorickpeterse.custom_fields'
  ext.directory   = __DIR__('custom_fields')
  
  ext.menu = [{
    :title => "Custom Fields",
    :url   => "admin/custom_field_groups"
  }]
end