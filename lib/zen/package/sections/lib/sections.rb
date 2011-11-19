Zen::Package.add do |p|
  p.name       = :sections
  p.title      = 'sections.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'sections.description'
  p.root       = __DIR__('sections')
  p.migrations = __DIR__('../migrations')

  p.menu('sections.titles.index', '/admin', :permission => :show_section)

  p.permission :show_section  , 'sections.permissions.show'
  p.permission :edit_section  , 'sections.permissions.edit'
  p.permission :new_section   , 'sections.permissions.new'
  p.permission :delete_section, 'sections.permissions.delete'

  p.permission :show_section_entry  , 'section_entries.permissions.show'
  p.permission :edit_section_entry  , 'section_entries.permissions.edit'
  p.permission :new_section_entry   , 'section_entries.permissions.new'
  p.permission :delete_section_entry, 'section_entries.permissions.delete'
end

Zen::Language.load('sections')
Zen::Language.load('section_entries')

require __DIR__('sections/model/section')
require __DIR__('sections/model/section_entry')
require __DIR__('sections/model/section_entry_status')
require __DIR__('sections/controller/sections')
require __DIR__('sections/controller/section_entries')

Zen::Controller::FrontendController.helper(:section_frontend)

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.default_section'
  setting.description = 'settings.descriptions.default_section'
  setting.name        = 'default_section'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = lambda do
    section_hash = {}

    Sections::Model::Section.select(:name, :id).each do |s|
      section_hash[s.id] = s.name
    end

    return section_hash
  end
end
