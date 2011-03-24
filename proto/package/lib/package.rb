Zen::Package.add do |p|
  # The name of the package
  p.name        = '' 

  # The person/company that made the package
  p.author      = ''

  # A URL to a page about the package
  p.url         = ''

  # Describe what your theme or extension does.
  p.about       = ''

  ## 
  # An identifier is a unique string for your package in the following format: 
  # 
  #     com.VENDOR.NAME
  #
  p.identifier  = 'com.vendor.module'

  ##
  # Path to the directory containing the controllers, models, etc.
  #
  p.directory   = __DIR__('package')
  
  # Note that themes can not have menu items (they'll be ignored).
  p.menu = [{
    :title => "",
    :url   => ""
  }]
end
