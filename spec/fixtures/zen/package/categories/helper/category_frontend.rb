class SpecCategoryFrontend < Zen::Controller::FrontendController
  map '/spec-category-frontend'

  def index
    categories = get_categories('Spec group', :limit => 1, :paginate => true)
    html       = ''

    categories.each do |category|
      html += "<p>#{category.name}</p>"
    end

    html += categories.navigation

    return html
  end
end
