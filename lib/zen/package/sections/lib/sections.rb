require __DIR__('sections/model/section')
require __DIR__('sections/model/section_entry')
require __DIR__('sections/controller/sections')
require __DIR__('sections/controller/section_entries')
require __DIR__('sections/plugin/sections')
require __DIR__('sections/plugin/section_entries')

Zen::Package.add do |p|
  p.name        = 'sections'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.about       = "The sections module allows users to create and manage sections. 
Sections can be seen as small web applications that live inside the CMS. 
For example, you could have a section for your blog and for your pages."
  
  p.directory     = __DIR__('sections')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Sections",
    :url   => "admin"
  }]

  p.controllers = [
    Sections::Controller::Sections, Sections::Controller::SectionEntries
  ]
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
