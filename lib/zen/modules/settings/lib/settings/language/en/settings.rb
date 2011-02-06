Zen::Language.translation 'settings' do |item|
  
  boolean_hash = {"Yes" => '1', "No" => '0'}
  section_hash = {}
  
  Sections::Models::Section.select(:name, :slug).each do |s|
    section_hash[s.slug] = s.name
  end
  
  item.titles = {
    :index => 'Settings'
  }
  
  item.labels = {
    :website_name        => 'Website name',
    :website_description => 'Website description',
    :website_enabled     => 'Website enabled',
    :language            => 'Language',
    :default_section     => 'Default section',
    :theme               => 'Theme',
    :enable_antispam     => 'Enable anti-spam',
    :defensio_key        => 'Defensio API key'
  }
  
  item.tabs = {
    :general  => 'General',
    :security => 'Security'
  }

  item.buttons = {
    :save => "Save"
  }
  
  item.success = {
    :save => "The settings have been saved"
  }
  
  item.errors = {
    :save => "The settings could not be saved"
  }
  
  item.values = {
    :website_enabled  => boolean_hash,
    :language         => {"en" => "English"},
    :enable_antispam  => boolean_hash,
    :default_section  => section_hash
  }
end