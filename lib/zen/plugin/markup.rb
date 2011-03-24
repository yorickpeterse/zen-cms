Zen::Plugin.add do |plugin|
  plugin.name       = 'Markup'
  plugin.author     = 'Yorick Peterse'
  plugin.about      = 'Plugin used for converting various markup formats to HTML.'
  plugin.identifier = 'com.zen.plugin.markup'
  plugin.actions    = {

    # Converts HTML to, well, HTML.
    :html => lambda do |markup|
      markup
    end,

    # Converts the given markup to plain text by escaping all HTML
    :plain => lambda do |markup|
      h(markup)
    end,

    # Comvert Markdown documents to HTML
    :markdown => lambda do |markup|
      RDiscount.new(markup).to_html
    end,

    # Convert Textile documents to HTML
    :textile => lambda do |markup|
      RedCloth.new(markup).to_html
    end

  } 
end
