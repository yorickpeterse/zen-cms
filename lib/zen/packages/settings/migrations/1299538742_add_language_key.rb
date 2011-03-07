Sequel.migration do

  up do
    add_column(:settings, :language_key, String) 

    # Set the correct values for all rows
    Zen::Database.handle[:settings].filter(:key => 'website_name')
      .update(:language_key => 'settings.labels.website_name')

    Zen::Database.handle[:settings].filter(:key => 'website_description')
      .update(:language_key => 'settings.labels.website_description')

    Zen::Database.handle[:settings].filter(:key => 'website_enabled')
      .update(:language_key => 'settings.labels.website_enabled')

    Zen::Database.handle[:settings].filter(:key => 'language')
      .update(:language_key => 'settings.labels.language')

    Zen::Database.handle[:settings].filter(:key => 'default_section')
      .update(:language_key => 'settings.labels.default_section')

    Zen::Database.handle[:settings].filter(:key => 'theme')
      .update(:language_key => 'settings.labels.theme')

    Zen::Database.handle[:settings].filter(:key => 'enable_antispam')
      .update(:language_key => 'settings.labels.enable_antispam')

    Zen::Database.handle[:settings].filter(:key => 'defensio_key')
      .update(:language_key => 'settings.labels.defensio_key')
  end
  
  down do
    drop_column(:settings, :language_key)
  end

end
