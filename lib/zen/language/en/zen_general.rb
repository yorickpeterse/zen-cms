Zen::Language.translation 'zen_general' do |item|
  
  item.labels = {
    :zen_version  => "Powered by Zen version #{Zen::Version}",
    :zen_website  => "Website",
    :zen_docs     => "Documentation",
    :zen_github   => "GitHub Account",
    :view_website => "View Website",
    :logout       => "Logout",
    :profile      => "Profile"
  }
  
  item.errors = {
    :csrf            => "The specified request can't be executed without a valid CSRF token.",
    :not_authorized  => "You are not authorized to access the current page.",
    :website_offline => "This website is currently offline.",
    :no_templates    => "No templates were found for the given action.",
    :no_theme        => "Before using Zen you'll need to specify a theme to use."
  }
  
end