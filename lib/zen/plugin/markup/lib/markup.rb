# Load our language packs
Zen::Language.options.paths.push(__DIR__('markup'))
Zen::Language.load('markup')

# Load the actual plugin
require __DIR__('markup/markup')

# Describe the plugin
Zen::Plugin.add do |plugin|
  plugin.name       = 'Markup'
  plugin.author     = 'Yorick Peterse'
  plugin.about      = 'Plugin used for converting various markup formats to HTML.'
  plugin.identifier = 'com.zen.plugin.markup'
  plugin.plugin     = Zen::Plugin::Markup
end
