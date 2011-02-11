
Zen::Package.add do |p|
  # The type of extension. Can either be "theme" or "extension".
  p.type        = ''

  # The name of the package
  p.name        = '' 

  # The person/company that made the package
  p.author      = ''

  # A URL to a page about the package
  p.url         = ''

  # The version number of the package
  p.version     = '1.0'

  # Describe what your theme or extension does.
  p.about       = ''

  ## 
  # An identifier is a unique string for your package in the following format: 
  # 
  # * com.AUTHOR.NAME for extensions
  # * com.AUTHOR.themes.NAME for themes
  #
  # An example of this would be "com.zen.sections" or "com.zen.themes.zen_website".
  #
  p.identifier  = 'com.author.module'

  ##
  # Path to the directory containing the controllers, models, etc.
  #
  p.directory   = __DIR__('modules')
  
  # Note that themes can not have menu items (they'll be ignored).
  p.menu = [{
    :title => "",
    :url   => ""
  }]
end
