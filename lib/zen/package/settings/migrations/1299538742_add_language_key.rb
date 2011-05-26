Sequel.migration do

  up do
    add_column(:settings, :language_key      , String) 
    add_column(:settings, :language_group_key, String)

    # Set the correct values for all rows
    Zen.database[:settings].filter(:key => 'website_name') \
      .update(
        :language_key       => 'settings.labels.website_name',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'website_description') \
      .update(
        :language_key       => 'settings.labels.website_description',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'website_enabled') \
      .update(
        :language_key       => 'settings.labels.website_enabled',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'language') \
      .update(
        :language_key       => 'settings.labels.language',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'default_section') \
      .update(
        :language_key       => 'settings.labels.default_section',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'theme') \
      .update(
        :language_key       => 'settings.labels.theme',
        :language_group_key => 'settings.tabs.general'
      )

    Zen.database[:settings].filter(:key => 'enable_antispam') \
      .update(
        :language_key       => 'settings.labels.enable_antispam',
        :language_group_key => 'settings.tabs.security'
      )

    Zen.database[:settings].filter(:key => 'defensio_key') \
      .update(
        :language_key       => 'settings.labels.defensio_key',
        :language_group_key => 'settings.tabs.security'
      )
  end
  
  down do
    drop_column(:settings, :language_key)
    drop_column(:settings, :language_group_key)
  end

end
