Sequel.migration do

  up do
    rename_column(:access_rules, :extension, :package)
    add_column(:access_rules, :controller, String, :null => false, :default => '*')
  end
  
  down do
    rename_column(:access_rules, :package, :extension)
    drop_column(:access_rules, :controller)
  end

end
