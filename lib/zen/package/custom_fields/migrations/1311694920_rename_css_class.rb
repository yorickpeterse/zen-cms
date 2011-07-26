Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    rename_column(:custom_field_types, :css_class, :html_class)
  end

  # Reverts the changes made in the up() block.
  down do
    rename_column(:custom_field_types, :html_class, :css_class)
  end
end
