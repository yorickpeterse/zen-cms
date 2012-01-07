Zen::Package.add do |p|
  p.name   = :extensions
  p.title  = 'extensions.titles.index'
  p.author = 'Yorick Peterse'
  p.url    = 'http://zen-cms.com/'
  p.about  = 'extensions.description'
  p.root   = __DIR__('extensions')

  p.menu 'extensions.titles.index',
    '/admin/extensions',
    :permission => :show_extension

  p.permission :show_extension, 'extensions.permissions.show'
end

require __DIR__('extensions/controller/extensions')

Zen::Event.listen :post_start do
  Zen::Language.load('extensions')
end
