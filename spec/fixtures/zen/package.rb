class SpecPackage < Zen::Controller::AdminController
  map '/admin/spec'

  def index
    Zen::Package.build_menu('spec_menu', extension_permissions)
  end
end

Zen::Package.add do |p|
  p.name        = 'spec'
  p.author      = 'Yorick Peterse'
  p.about       = 'A spec extension'
  p.url         = 'http://zen-cms.com/'
  p.directory   = __DIR__
  p.menu        = [{:title => 'Spec', :url => '/admin/spec'} ]
  p.controllers = {'Spec' => SpecPackage}
end
