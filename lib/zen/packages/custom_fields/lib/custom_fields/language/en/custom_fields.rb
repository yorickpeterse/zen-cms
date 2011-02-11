Zen::Language.translation 'custom_fields' do |item|
  # Page titles
  item.titles = {
    :index  => 'Custom Fields',
    :edit   => 'Edit Custom Field',
    :new    => 'Add Custom Field'
  }
  
  # Labels
  item.labels = {
    :id                => '#',
    :name              => 'Name',
    :slug              => 'Slug',
    :type              => 'Type',
    :format            => 'Format',
    :description       => 'Description',
    :possible_values   => 'Possible values (one value per line)',
    :required          => 'Requires a value',
    :visual_editor     => 'Enable the visual editor',
    :textarea_rows     => 'Textarea rows',
    :text_limit        => 'Character limit',
    :sort_order        => 'Sort order'
  }
  
  item.tabs = {
    :general  => 'General',
    :settings => 'Settings'
  }

  # General messages
  item.messages = {
    :no_fields    => 'It seems you haven\'t created any custom fields yet.'
  }
  
  # Error specific messages
  item.errors = {
    :new        => "Failed to create a new custom field.",
    :save       => "Failed to save the custom field.",
    :delete     => "Failed to delete the custom field with ID #%s",
    :no_delete  => "You haven't specified any custom fields to delete."
  }
  
  # Success messages
  item.success = {
    :new    => "The new custom field has been created.",
    :save   => "The custom field has been modified.",
    :delete => "The custom field with ID #%s has been deleted."
  }
  
  # Special items such as hashes for field types
  item.special = {
    :format_hash  => {"html" => "HTML", "textile" => "Textile", "markdown" => "Markdown", "plain" => "Plain"},
    :type_hash    => {"textbox" => "Textbox", "textarea" => "Textarea", "radio" => "Radio button",
      "checkbox"  => "Checkbox", "date" => "Date", "select" => "Select", "select_multiple" => "Multi select"},
    :boolean_hash => {"Yes" => true, "No" => false}
  }
  
  # Buttons
  item.buttons = {
    :new_field     => 'New field',
    :delete_fields => 'Delete selected fields',
    :save_field    => 'Save field'
  }
end