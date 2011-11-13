Sequel.migration do
  up do
    alter_table(:settings) do
      drop_column(:group)
      drop_column(:default)
      drop_column(:type)
    end
  end

  down do
    alter_table(:settings) do
      add_column(:group, String)
      add_column(:default, String)
      add_column(:type, String)
    end
  end
end
