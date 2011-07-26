Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    rename_column(:menu_items, :css_class, :html_class)
    rename_column(:menu_items, :css_id   , :html_id)
    rename_column(:menus     , :css_class, :html_class)
    rename_column(:menus     , :css_id   , :html_id)
  end

  # Reverts the changes made in the up() block.
  down do
    rename_column(:menu_items, :html_class, :css_class)
    rename_column(:menu_items, :html_id   , :css_id)
    rename_column(:menus     , :html_class, :css_class)
    rename_column(:menus     , :html_id   , :css_id)
  end
end
