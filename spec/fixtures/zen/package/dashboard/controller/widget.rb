class SpecWidget < Zen::Controller::AdminController
  map '/admin/spec-widget'

  def index
    return Dashboard::Widget.html
  end

  def columns
    return Dashboard::Widget.columns_html
  end

  def checkbox
    return Dashboard::Widget.checkbox_html
  end
end # SpecWidget
