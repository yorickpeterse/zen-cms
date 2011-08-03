class SpecMessageHelper < Zen::Controller::AdminController
  map '/admin/spec-message-helper'

  def index
    return display_messages
  end

  def success
    message(:success, 'success message')
  end

  def info
    message(:info, 'info message')
  end

  def error
    message(:error, 'error message')
  end
end
