class SpecControllerHelper < Zen::Controller::AdminController
  map   '/admin/spec-controller-helper'
  title 'categories.titles.%s'
  csrf_protection :csrf

  def index
    return 'index method'
  end

  def csrf
    return 'csrf method'
  end
end
