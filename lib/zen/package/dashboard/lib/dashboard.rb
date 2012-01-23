Zen::Package.add do |p|
  p.name       = :dashboard
  p.title      = 'dashboard.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'dashboard.description'
  p.root       = __DIR__('dashboard')
  p.migrations = __DIR__('../migrations')

  p.menu 'dashboard.titles.index', '/admin/dashboard'
end

require __DIR__('dashboard/model/widget')
require __DIR__('dashboard/controller/dashboard')
require __DIR__('dashboard/widget')
require __DIR__('dashboard/widget/welcome')

Zen::Event.listen :post_start do
  Zen::Language.load('dashboard')
end
