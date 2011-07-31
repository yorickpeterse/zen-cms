class SpecACLHelper < Zen::Controller::AdminController
  map '/admin/spec-acl-helper'

  # Hash used to store the data in for each spec rather than returning it and
  # having to encode/decode it using Marshal.
  SpecData = {
    :permissions => nil
  }

  # Don't cache the access rules in the session.
  after_all do
    session.delete(:access_rules) if session[:access_rules]
  end

  # returns all permissions
  def index
    SpecData[:permissions] = extension_permissions
  end

  def require_all
    if user_authorized?([:create, :read], true, 'Users::Controller::Users')
      return 'authorized'
    else
      return 'not authorized'
    end
  end

  def require_one
    if user_authorized?([:create, :delete], false, 'Users::Controller::Users')
      return 'authorized'
    else
      return 'not authorized'
    end
  end

  def require_permissions_block
    require_permissions(:delete, :update)
  end
end
