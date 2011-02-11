Sequel.migration do

  up do
    drop_column :sections, :comment_antispam
  end
  
  down do
    add_column :sections, :comment_antispam, TrueClass, :default => true, :null => false
  end

end