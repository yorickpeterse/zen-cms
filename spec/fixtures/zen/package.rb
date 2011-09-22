class SpecPackage < Zen::Controller::AdminController
  map '/admin/spec'

  def index
    Zen::Package.build_menu('spec_menu', extension_permissions)
  end
end
