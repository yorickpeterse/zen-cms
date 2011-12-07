Zen::Package.add do |p|
  p.name       = :custom_fields
  p.title      = 'custom_fields.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'custom_fields.description'
  p.root       = __DIR__('custom_fields')
  p.migrations = __DIR__('../migrations')

  p.menu(
    'custom_fields.titles.index',
    '/admin/custom-field-groups',
    :permission => :show_custom_field_group
  )

  p.menu(
    'custom_field_types.titles.index',
    '/admin/custom-field-types',
    :permission => :show_custom_field
  )

  p.permission :show_custom_field_group, 'custom_field_groups.permissions.show'
  p.permission :edit_custom_field_group, 'custom_field_groups.permissions.edit'
  p.permission :new_custom_field_group , 'custom_field_groups.permissions.new'
  p.permission :delete_custom_field_group,
    'custom_field_groups.permissions.delete'

  p.permission :show_custom_field_type  , 'custom_field_types.permissions.show'
  p.permission :edit_custom_field_type  , 'custom_field_types.permissions.edit'
  p.permission :new_custom_field_type   , 'custom_field_types.permissions.new'
  p.permission :delete_custom_field_type, 'custom_field_types.permissions.delete'

  p.permission :show_custom_field  , 'custom_fields.permissions.show'
  p.permission :edit_custom_field  , 'custom_fields.permissions.edit'
  p.permission :new_custom_field   , 'custom_fields.permissions.new'
  p.permission :delete_custom_field, 'custom_fields.permissions.delete'
end

Zen::Language.load('custom_fields')
Zen::Language.load('custom_field_groups')
Zen::Language.load('custom_field_types')

require __DIR__('custom_fields/model/custom_field_method')
require __DIR__('custom_fields/model/custom_field_type')
require __DIR__('custom_fields/model/custom_field')
require __DIR__('custom_fields/model/custom_field_group')
require __DIR__('custom_fields/model/custom_field_value')

require __DIR__('custom_fields/controller/custom_field_groups')
require __DIR__('custom_fields/controller/custom_fields')
require __DIR__('custom_fields/controller/custom_field_types')

require __DIR__('custom_fields/blue_form_parameters')
