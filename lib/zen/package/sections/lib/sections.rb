
# Load all the classes such as controllers, models and so on.
require __DIR__('sections/model/section')
require __DIR__('sections/model/section_entry')
require __DIR__('sections/controller/sections')
require __DIR__('sections/controller/section_entries')

# Load and register all our liquid tags
require __DIR__('sections/liquid/section_entries')
require __DIR__('sections/liquid/sections')

# Load all plugins
require __DIR__('sections/plugin/sections')
require __DIR__('sections/plugin/section_entries')

Liquid::Template.register_tag('sections', Sections::Liquid::Sections)
Liquid::Template.register_tag('section_entries', Sections::Liquid::SectionEntries)

# Describe what this extension is all about
Zen::Package.add do |p|
  p.name        = 'Sections'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.about       = "The sections module allows users to create and manage sections. 
Sections can be seen as small web applications that live inside the CMS. 
For example, you could have a section for your blog and for your pages."
  
  p.identifier    = 'com.zen.sections'
  p.directory     = __DIR__('sections')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Sections",
    :url   => "admin"
  }]
end

Zen::Plugin.add do |p|
  p.name       = 'Sections'
  p.author     = 'Yorick Peterse'
  p.about      = 'Plugin for retrieving multiple or individual sections.'
  p.url        = 'http://yorickpeterse.com/'
  p.identifier = 'com.zen.plugin.sections'
  p.plugin     = Sections::Plugin::Sections
end

Zen::Plugin.add do |p|
  p.name       = 'Section Entries'
  p.author     = 'Yorick Peterse'
  p.about      = 'Plugin for retrieving multiple or individual section entries.'
  p.url        = 'http://yorickpeterse.com/'
  p.identifier = 'com.zen.plugin.section_entries'
  p.plugin     = Sections::Plugin::SectionEntries
end
