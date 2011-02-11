Zen::Language.translation 'access_rules' do |item|

  item.titles = {
    :index  => 'Access Rules',
    :edit   => 'Edit Access Rule',
    :new    => 'Add Access Rule'
  }
  
  item.labels = {
    :id           => '#',
    :extension    => 'Extension',
    :rule_applies => 'Rule applies to',
    :create       => 'Create',
    :read         => 'Read',
    :update       => 'Update',
    :delete       => 'Delete',
    :user         => 'User',
    :user_group   => 'User group'
  }
  
  item.special = {
    :boolean_hash      => {true => "Yes", false => "No"},
    :rule_applies_hash => {"Users" => "div_user_id", "User groups" => "div_user_group_id"}
  }

  item.messages = {
    :no_rules    => 'No access rules have been added yet'
  }
  
  item.errors = {
    :new        => "Failed to create a new access rule.",
    :save       => "Failed to save the access rule.",
    :delete     => "Failed to delete the access rule with ID #%s",
    :no_delete  => "You haven't specified any access rules to delete."
  }
  
  item.success = {
    :new    => "The new access rule has been created.",
    :save   => "The access rule has been modified.",
    :delete => "The access rule with ID #%s has been deleted."
  }
  
  item.buttons = {
    :new    => 'New rule',
    :delete => 'Delete selected rules',
    :save   => 'Save rule'
  }

end