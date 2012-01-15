Zen::Package.add do |p|
  p.name       = :dashboard
  p.title      = 'Dashboard'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'Dashboard with custom widgets for each user.'
  p.root       = __DIR__('dashboard')
  p.migrations = __DIR__('../migrations')

  p.menu 'Dashboard', '/admin/dashboard'
end

require __DIR__('dashboard/model/widget')
require __DIR__('dashboard/controller/dashboard')

require __DIR__('dashboard/widget')

#Zen::Event.listen :post_start do
#  Zen::Language.load('dashboard')
#end
