
# Update the list of helper paths
Ramaze::HelpersHelper.options.paths << __DIR__('menus')

# Load all our models
require __DIR__('menus/model/menu')
require __DIR__('menus/model/menu_item')

# Load all controllers
require __DIR__('menus/controller/menus')
require __DIR__('menus/controller/menu_items')

# Load all Liquid tags and register them
require __DIR__('menus/liquid/menus')

Liquid::Template.register_tag('menus', Menus::Liquid::Menus)

# Describe the package
Zen::Package.add do |p|
  # The type of extension. Can either be "theme" or "extension".
  p.type        = 'extension'

  # The name of the package
  p.name        = 'Menus' 

  # The person/company that made the package
  p.author      = 'Yorick Peterse'

  # A URL to a page about the package
  p.url         = 'http://zen-cms.com/userguide/menus'

  # The version number of the package
  p.version     = '1.0'

  # Describe what your theme or extension does.
  p.about       = 'The Menus extension allows you to easily create navigation menus 
for the frontend.'

  ## 
  # An identifier is a unique string for your package in the following format: 
  # 
  # * com.AUTHOR.NAME for extensions
  # * com.AUTHOR.themes.NAME for themes
  #
  # An example of this would be "com.zen.sections" or "com.zen.themes.zen_website".
  #
  p.identifier  = 'com.zen.menus'

  ##
  # Path to the directory containing the controllers, models, etc.
  #
  p.directory   = __DIR__('menus')
  
  # Note that themes can not have menu items (they'll be ignored).
  p.menu = [{
    :title => "Menus",
    :url   => "/admin/menus"
  }]
end
