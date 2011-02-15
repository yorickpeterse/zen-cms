Zen::Language.translation 'category_groups' do |item|

  item.titles = {
    :index => 'Category Groups',
    :edit  => 'Edit Category Group',
    :new   => 'Add Category Group'
  }
  
  item.labels = {
    :id                => '#',
    :name              => 'Name',
    :description       => 'Description',
    :manage_categories => 'Manage categories'
  }

  item.placeholders = {
    :name        => 'The name of the category group.',
    :description => 'Describe what the category group is for.'
  }
  
  item.messages = {
    :no_groups   => 'No category groups have been created yet.'
  }
  
  item.success = {
    :new      => 'The category group has been created',
    :save     => 'The category group has been saved',
    :delete   => 'The category group with ID #%s has been deleted'
  }
  
  item.errors = {
    :new        => 'Failed to add the category group',
    :save       => 'Failed to save the category group',
    :delete     => 'Failed to delete the cateogry group with ID #%s',
    :no_delete  => 'You haven\'t specified any category groups to delete'
  }
  
  item.buttons = {
    :new_group      => 'New group',
    :save_group     => 'Save group',
    :delete_groups  => 'Delete selected groups'
  }

end
