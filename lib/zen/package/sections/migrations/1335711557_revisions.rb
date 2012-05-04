Sequel.migration do
  up do
    create_table :revisions do
      primary_key :id

      Time :created_at

      foreign_key :user_id,
        :users,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id

      foreign_key :section_entry_id,
        :section_entries,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id
    end

    alter_table :section_entries do
      add_foreign_key :revision_id, :revisions,
        :on_update => :cascade,
        :on_delete => :set_null,
        :key       => :id
    end
  end

  down do
    alter_table :section_entries do
      if Zen.database.database_type.to_s.include?('mysql')
        drop_constraint :custom_field_values_ibfk_4, :type => :foreign_key
      end

      drop_column :revision_id
    end

    drop_table :revisions
  end
end
