Sequel.migration do
  up do
    alter_table :custom_field_values do
      add_foreign_key :revision_id, :revisions,
        :on_update => :cascade,
        :on_delete => :cascade,
        :key       => :id
    end

    # Create a revision for each existing entry.
    entries = Zen.database[:section_entries] \
      .select(:id, :user_id) \
      .order(:id.asc)

    entries.each do |entry|
      rev_id = Zen.database[:revisions].insert(
        :created_at       => Time.now,
        :user_id          => entry[:user_id],
        :section_entry_id => entry[:id]
      )

      Zen.database[:section_entries] \
        .filter(:id => entry[:id]) \
        .update(:revision_id => rev_id)

      Zen.database[:custom_field_values] \
        .filter(:section_entry_id => entry[:id]) \
        .update(:revision_id => rev_id)
    end
  end

  down do
    alter_table :custom_field_values do
      if Zen.database.database_type.to_s.include?('mysql')
        drop_constraint :custom_field_values_ibfk_3, :type => :foreign_key
      end

      drop_column :revision_id
    end
  end
end
