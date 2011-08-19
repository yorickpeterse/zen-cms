class SpecLocaleHelper < Zen::Controller::AdminController
  map '/admin/spec-locale-helper'

  def index
    date_format
  end
end
