Zen::Language.translation "menus" do |item|
  
  item.titles = {
    :index => "Menus",
    :edit  => "Edit Menu",
    :new   => "Add Menu"
  }

  item.labels = {
    :id           => "#",
    :name         => "Name",
    :slug         => "Slug",
    :description  => "Description",
    :css_class    => "CSS class",
    :css_id       => "CSS ID",
    :manage_items => "Manage menu items"
  }

  item.placeholders = {
    :name      => "Specify the name of the menu",
    :slug      => "Specify the URL friendly name of the menu",
    :css_class => "Specify a class name to use in stylesheets",
    :css_id    => "Specify a ID to use in stylesheets"
  }

  item.buttons = {
    :new    => "Add menu",
    :save   => "Save menu",
    :delete => "Delete selected menus"
  }

  item.messages = {
    :no_menus => "No menus have been added yet."
  }

  item.success = {
    :new    => "The menu has been created.",
    :save   => "The menu has been modified.",
    :delete => "The menu has been deleted."
  }

  item.errors = {
    :new       => "The menu could not be created.",
    :save      => "The menu could not be modified.",
    :delete    => "The menu with ID #%s could not be removed.",
    :no_delete => "You need to specify at least one menu to delete."
  }
end
