Zen::Language.translation 'categories' do |item|

  item.titles = {
    :index => 'Categories',
    :edit  => 'Edit Category',
    :new   => 'Add Category'
  }
  
  item.labels = {
    :id           => '#',
    :name         => 'Name',
    :description  => 'Description',
    :parent       => 'Parent',
    :slug         => 'Slug'
  }

  item.placeholders = {
    :name    => 'The name of the category.',
    :slug    => 'A URL friendly name of the category.'
  }
  
  item.messages = {
    :no_categories => 'No categories have been created yet.'
  }
  
  item.success = {
    :new    => 'The category has been created',
    :save   => 'The category has been saved',
    :delete => 'The selected categories have been deleted'
  }
  
  item.errors = {
    :new        => 'Failed to add the category',
    :save       => 'Failed to save the category',
    :delete     => 'Failed to delete the cateogry with ID #%s',
    :no_delete  => 'You haven\'t specified any categories to delete'
  }
  
  item.buttons = {
    :new_category      => 'New category',
    :save_category     => 'Save category',
    :delete_categories => 'Delete selected categories'
  }

end
