Zen::Language.translation 'custom_field_groups' do |item|
  # Page titles
  item.titles = {
    :index  => 'Custom Field Groups',
    :edit   => 'Edit Custom Field Group',
    :new    => 'Add Custom Field Group'
  }
  
  # Labels
  item.labels = {
    :id                => '#',
    :name              => 'Name',
    :description       => 'Description',
    :sections          => 'Sections',
    :manage_fields     => 'Manage Custom Fields',
    :none              => 'None'
  }

  # General messages
  item.messages = {
    :no_groups    => 'It seems you haven\'t created any custom field groups yet.'
  }
  
  # Error specific messages
  item.errors = {
    :new        => "Failed to create a new custom field group.",
    :save       => "Failed to save the custom field group.",
    :delete     => "Failed to delete the custom field group with ID #%s",
    :no_delete  => "You haven't specified any custom field groups to delete."
  }
  
  # Success messages
  item.success = {
    :new    => "The new custom field group has been created.",
    :save   => "The custom field group has been modified.",
    :delete => "The custom field group with ID #%s has been deleted."
  }
  
  # Buttons
  item.buttons = {
    :new_group     => 'New group',
    :delete_groups => 'Delete selected groups',
    :save_group    => 'Save group'
  }
end