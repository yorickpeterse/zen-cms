Zen::Package.add do |p|
  p.name       = :sections
  p.title      = 'sections.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'sections.description'
  p.root       = __DIR__('sections')
  p.migrations = __DIR__('../migrations')

  p.menu 'sections.titles.index',
    '/admin/sections',
    :permission => :show_section

  p.permission :show_section  , 'sections.permissions.show'
  p.permission :edit_section  , 'sections.permissions.edit'
  p.permission :new_section   , 'sections.permissions.new'
  p.permission :delete_section, 'sections.permissions.delete'

  p.permission :show_section_entry  , 'section_entries.permissions.show'
  p.permission :edit_section_entry  , 'section_entries.permissions.edit'
  p.permission :new_section_entry   , 'section_entries.permissions.new'
  p.permission :delete_section_entry, 'section_entries.permissions.delete'
end

require __DIR__('sections/model/section')
require __DIR__('sections/model/section_entry')
require __DIR__('sections/model/section_entry_status')
require __DIR__('sections/controller/sections')
require __DIR__('sections/controller/section_entries')
require __DIR__('sections/widget/recent_entries')

Zen::Controller::FrontendController.helper(:section_frontend)

Zen::Event.listen :post_start do
  Zen::Language.load('sections')
  Zen::Language.load('section_entries')
end
