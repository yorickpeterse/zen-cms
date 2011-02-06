Zen::Language.translation 'user_groups' do |item|
  item.titles = {
    :index  => 'User Groups',
    :edit   => 'Edit User Group',
    :new    => 'Add User Group'
  }
  
  item.labels = {
    :id          => '#',
    :name        => 'Name',
    :slug        => 'Slug',
    :description => 'Description',
    :super_group => 'Super group'
  }
  
  item.special = {
    :boolean_hash => {true => "Yes", false => "No"}
  }

  item.messages = {
    :no_user_groups  => 'No user groups have been added yet'
  }
  
  item.errors = {
    :new        => "Failed to create a new user group.",
    :save       => "Failed to save the user group.",
    :delete     => "Failed to delete the user group with ID #%s",
    :no_delete  => "You haven't specified any user groups to delete."
  }
  
  item.success = {
    :new    => "The new user group has been created.",
    :save   => "The user group has been modified.",
    :delete => "The user group with ID #%s has been deleted."
  }
  
  item.buttons = {
    :new_group     => 'New group',
    :delete_groups => 'Delete selected groups',
    :save_group    => 'Save group'
  }
end