class SpecACLHelper < Zen::Controller::AdminController
  map '/admin/spec-acl-helper'

  def index
    if user_authorized?(:spec_permission)
      respond('allowed', 200)
    else
      respond('not allowed', 200)
    end
  end

  def invalid
    if user_authorized?(:invalid_permission)
      respond('allowed', 200)
    else
      respond('not allowed', 200)
    end
  end

  def respond_message
    authorize_user!(:invalid_permission)
  end
end
