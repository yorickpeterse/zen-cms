Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    rename_column(:menu_items, :order, :sort_order) 
  end
  
  # Reverts the changes made in the up() block.
  down do
    rename_column(:menu_items, :sort_order, :order)
  end
end
