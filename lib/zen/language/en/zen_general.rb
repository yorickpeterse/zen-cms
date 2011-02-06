Zen::Language.translation 'general' do |item|
  
  item.errors = {
    :csrf            => "The specified request can't be executed without a valid CSRF token.",
    :not_authorized  => "You are not authorized to access the current page.",
    :website_offline => "This website is currently offline.",
    :no_templates    => "No templates were found for the given action."
  }
  
end