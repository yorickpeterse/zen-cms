Ramaze::HelpersHelper.options.paths.push(__DIR__('custom_fields'))
Zen::Language.options.paths.push(__DIR__('custom_fields'))

# Load all models
require __DIR__('custom_fields/model/custom_field_method')
require __DIR__('custom_fields/model/custom_field_type')
require __DIR__('custom_fields/model/custom_field')
require __DIR__('custom_fields/model/custom_field_group')
require __DIR__('custom_fields/model/custom_field_value')

# Load all controllers
require __DIR__('custom_fields/controller/custom_field_groups')
require __DIR__('custom_fields/controller/custom_fields')
require __DIR__('custom_fields/controller/custom_field_types')

require __DIR__('custom_fields/blue_form_parameters')

# Load all the language files
Zen::Language.load('custom_fields')
Zen::Language.load('custom_field_groups')
Zen::Language.load('custom_field_types')

# Define the package
Zen::Package.add do |p|
  p.name          = 'custom_fields'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "The Custom Fields module is used to manage custom " \
    "fields and custom field groups."

  p.directory     = __DIR__('custom_fields')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title    => lang('custom_fields.titles.index'),
    :url      => "admin/custom-field-groups",
    :children => [
      {
        :title => lang('custom_field_types.titles.index'),
        :url   => 'admin/custom-field-types'
      }
    ]
  }]

  p.controllers = {
    lang('custom_fields.titles.index') \
      => CustomFields::Controller::CustomFields,
    lang('custom_field_groups.titles.index') \
      => CustomFields::Controller::CustomFieldGroups,
    lang('custom_field_types.titles.index') \
      => CustomFields::Controller::CustomFieldTypes
  }
end
