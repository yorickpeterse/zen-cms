require __DIR__('markup/markup')

Zen::Plugin.add do |plugin|
  plugin.name       = 'Markup'
  plugin.author     = 'Yorick Peterse'
  plugin.about      = 'Plugin used for converting various markup formats to HTML.'
  plugin.identifier = 'com.zen.plugin.markup'
  plugin.plugin     = Zen::Plugin::Markup
end
