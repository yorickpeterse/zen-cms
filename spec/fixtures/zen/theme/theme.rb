Zen::Theme.add do |theme|
  theme.name   = 'spec_theme'
  theme.author = 'Yorick Peterse'
  theme.url    = 'http://zen-cms.com/'
  theme.about  = 'A theme for all the tests'

  # Add all directories
  theme.template_dir  = __DIR__
  theme.partial_dir   = __DIR__('partials')
end

