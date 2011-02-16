Zen::Language.translation 'menu_items' do |item|

  item.titles = {
    :index => 'Menu Items',
    :edit  => 'Edit Menu Item',
    :new   => 'Create Menu Item'
  }

  item.labels = {
    :id        => '#',
    :parent_id => 'Parent',
    :name      => 'Name',
    :url       => 'URL',
    :order     => 'Order',
    :css_class => 'CSS class',
    :css_id    => 'CSS ID'
  }

  item.placeholders = {
    :name      => 'The text that will be displayed in the link',
    :url       => 'The location to which the link will point',
    :order     => 'A number that indicates the sort order',
    :css_class => 'Specify a class name to use for stylesheets',
    :css_id    => 'Specify a ID to use for stylesheets' 
  }

  item.messages = {
    :no_items  => 'No menu items have been added yet.'
  }

  item.buttons = {
    :new    => 'Add menu item',
    :save   => 'Save menu item',
    :delete => 'Delete selected items'
  }

  item.success = {
    :new       => 'The menu item has been created.',
    :save      => 'The menu item has been modified.',
    :delete    => 'All selected menu items have been deleted.'
  }

  item.errors = {
    :new          => 'The menu item could not be created.',
    :save         => 'The menu item could not be modified.',
    :delete       => 'The menu item with ID #%s could not be deleted.',
    :no_delete    => 'You need to specify at least one item to delete.',
    :invalid_menu => 'The specified menu was invalid or no longer exists.'
  }

end
