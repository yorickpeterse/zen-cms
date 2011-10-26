class SpecACLHelper < Zen::Controller::AdminController
  map '/admin/spec-acl-helper'

  def index
    if user_authorized?(:spec_permission)
      return 'allowed'
    else
      return 'now allowed'
    end
  end

  def invalid
    if user_authorized?(:invalid_permission)
      return 'allowed'
    else
      return 'not allowed'
    end
  end

  def respond_message
    authorize_user!(:invalid_permission)
  end
end
