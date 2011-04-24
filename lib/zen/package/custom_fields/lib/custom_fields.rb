require __DIR__('custom_fields/model/custom_field')
require __DIR__('custom_fields/model/custom_field_group')
require __DIR__('custom_fields/model/custom_field_value')
require __DIR__('custom_fields/controller/custom_field_groups')
require __DIR__('custom_fields/controller/custom_fields')

Zen::Language.options.paths.push(__DIR__('custom_fields'))
Zen::Language.load('custom_fields')
Zen::Language.load('custom_field_groups')

Zen::Package.add do |p|
  p.name          = 'custom_fields'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "The Custom Fields module is used to manage custom fields and custom 
field groups."

  p.directory     = __DIR__('custom_fields')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => lang('custom_fields.titles.index'),
    :url   => "admin/custom-field-groups"
  }]

  p.controllers = {
    lang('custom_fields.titles.index')       => CustomFields::Controller::CustomFields, 
    lang('custom_field_groups.titles.index') => CustomFields::Controller::CustomFieldGroups
  }
end
