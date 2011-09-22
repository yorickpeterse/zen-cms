Zen::Package.add do |p|
  p.name       = :sections
  p.title      = 'sections.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://yorickpeterse.com/'
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

require __DIR__('sections/plugin/sections')
require __DIR__('sections/plugin/section_entries')

Zen::Plugin.add do |p|
  p.name       = 'sections'
  p.author     = 'Yorick Peterse'
  p.about      = 'sections.plugins.sections'
  p.url        = 'http://yorickpeterse.com/'
  p.plugin     = Sections::Plugin::Sections
end

Zen::Plugin.add do |p|
  p.name       = 'section_entries'
  p.author     = 'Yorick Peterse'
  p.about      = 'sections.plugins.section_entries'
  p.url        = 'http://yorickpeterse.com/'
  p.plugin     = Sections::Plugin::SectionEntries
end

# Register all the settings
plugin(:settings, :register) do |setting|
  setting.title       = lang('settings.labels.default_section')
  setting.description = lang('settings.placeholders.default_section')
  setting.name        = 'default_section'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = lambda do
    section_hash = {}

    begin
      Sections::Model::Section.select(:name, :id).each do |s|
        section_hash[s.id] = s.name
      end

      return section_hash
    rescue => e
      Ramaze::Log.warn(
        "The settings plugin failed to retrieve all sections: #{e.message}"
      )
    end
  end
end
