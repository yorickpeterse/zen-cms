class SpecSectionFrontend < Zen::Controller::FrontendController
  map '/spec-section-frontend'

  def index
    entries = get_entries('spec', :limit => 1, :paginate => true)
    html    = ''

    entries.each do |entry|
      html += "<p>#{entry.title}</p>"
    end

    html += entries.navigation

    return html
  end
end
