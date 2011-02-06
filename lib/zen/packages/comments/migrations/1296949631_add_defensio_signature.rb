Sequel.migration do

  up do
    add_column :comments, :defensio_signature, String, :null => true
  end
  
  down do
    drop_column :comments, :defensio_signature
  end

end