Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    drop_column(:comments, :defensio_signature)
  end

  # Reverts the changes made in the up() block.
  down do
    add_column(:comments, :defensio_signature, String)
  end
end
