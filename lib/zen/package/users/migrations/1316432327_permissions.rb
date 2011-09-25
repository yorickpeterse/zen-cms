Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    drop_table(:access_rules)

    create_table(:permissions) do
      String :permission, :null => false

      # I'd love to use foreign keys here but I kept getting SQLite3 constraint
      # warnings that made *zero* sense as the data was correct (manually
      # inserting the data works just fine). Patches are welcome but do note
      # that I don't consider this a very high priority.
      Integer :user_id
      Integer :user_group_id
    end
  end

  # Reverts the changes made in the up() block.
  down do
    drop_table(:permissions)

    create_table(:access_rules) do
      String :package   , :null => false
      String :controller, :null => false, :default => '*'

      TrueClass :read_access,   :default => true,  :null => false
      TrueClass :create_access, :default => false, :null => false
      TrueClass :update_access, :default => false, :null => false
      TrueClass :delete_access, :default => false, :null => false

      # Not using real foreign keys as they can't be empty
      Integer :user_id
      Integer :user_group_id
    end
  end
end
