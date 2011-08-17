Ramaze::HelpersHelper.options.paths.push(__DIR__('sections'))
Zen::Language.options.paths.push(__DIR__('sections'))

require __DIR__('sections/model/section')
require __DIR__('sections/model/section_entry')
require __DIR__('sections/model/section_entry_status')

require __DIR__('sections/controller/sections')
require __DIR__('sections/controller/section_entries')

require __DIR__('sections/plugin/sections')
require __DIR__('sections/plugin/section_entries')

Zen::Language.load('sections')
Zen::Language.load('section_entries')

Zen::Package.add do |p|
  p.name        = 'sections'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.about       = 'The sections module allows users to create and manage sections.
Sections can be seen as small web applications that live inside the CMS.
For example, you could have a section for your blog and for your pages.'

  p.directory     = __DIR__('sections')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title => lang('sections.titles.index'),
    :url   => 'admin'
  }]

  p.controllers = {
    lang('sections.titles.index')        => Sections::Controller::Sections,
    lang('section_entries.titles.index') => Sections::Controller::SectionEntries
  }
end

Zen::Plugin.add do |p|
  p.name       = 'sections'
  p.author     = 'Yorick Peterse'
  p.about      = 'Plugin for retrieving multiple or individual sections.'
  p.url        = 'http://yorickpeterse.com/'
  p.plugin     = Sections::Plugin::Sections
end

Zen::Plugin.add do |p|
  p.name       = 'section_entries'
  p.author     = 'Yorick Peterse'
  p.about      = 'Plugin for retrieving multiple or individual section entries.'
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
      Sections::Model::Section.select(:name, :id).all.each do |s|
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
