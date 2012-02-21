# Registers a new theme to use for this project. See
# http://zen-cms.com/documentation/Zen/Theme.html for more information on all
# the available options and working with themes in general.
Zen::Theme.add do |theme|
  # The unique name of the theme specified as a symbol (required).
  theme.name = :default

  # The name of the author of the theme (required).
  theme.author = 'Zen'

  # A URL that points to a website/web page related to the theme.
  theme.url = 'http://zen-cms.com/'

  # A short description of the theme (required).
  theme.about = 'The default theme for Zen.'

  # The directory containing all the templates (required).
  theme.templates = __DIR__

  # The directory containing all template partials.
  theme.partials = __DIR__('partials')
end
