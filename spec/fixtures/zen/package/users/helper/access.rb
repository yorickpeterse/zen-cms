class SpecAccessHelper < Zen::Controller::AdminController
  map '/admin/spec-access-helper'
  helper :access

  allow [:allowed, :allowed_1]

  def denied
    return 'super secret page'
  end

  def allowed
    return 'allowed'
  end

  def allowed_1
    return 'allowed'
  end
end
