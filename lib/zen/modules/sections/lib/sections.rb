
# Load all the classes such as controllers, models and so on.
require __DIR__ 'sections/model/section'
require __DIR__ 'sections/model/section_entry'
require __DIR__ 'sections/controller/sections'
require __DIR__ 'sections/controller/section_entries'

# Load and register all our liquid tags
require __DIR__ 'sections/liquid/section_entries'
require __DIR__ 'sections/liquid/sections'

Liquid::Template.register_tag('sections', Sections::Liquid::Sections)
Liquid::Template.register_tag('section_entries', Sections::Liquid::SectionEntries)

# Describe what this extension is all about
Zen::Extension.add do |ext|
  ext.name        = 'Sections'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = "The sections module allows users to create and manage sections. 
Sections can be seen as small web applications that live inside the CMS. 
For example, you could have a section for your blog and for your pages."
  
  ext.identifier  = 'com.yorickpeterse.sections'
  ext.directory   = __DIR__('sections')
  
  ext.menu = [{
    :title => "Sections",
    :url   => "admin"
  }]
end