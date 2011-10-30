Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    create_table(:section_entry_statuses) do
      primary_key :id

      String :name, :null => false, :unique => true
    end

    # Get all existing entries
    entries = Zen.database[:section_entries].all

    # Replace the status column
    drop_column(:section_entries, :status)

    alter_table(:section_entries) do
      add_foreign_key(
        :section_entry_status_id,
        :section_entry_statuses,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id
      )
    end

    # Insert the statuses and migrate the existing entries
    ['published', 'draft'].each do |status|
      status_id = Zen.database[:section_entry_statuses].insert(:name => status)

      entries.each do |entry|
        if entry[:status] == status
          Zen.database[:section_entries].filter(:id => entry[:id]) \
            .update(:section_entry_status_id => status_id)
        end
      end
    end
  end

  # Reverts the changes made in the up() block.
  down do
    statuses = {}
    entries  = Zen.database[:section_entries].all

    Zen.database[:section_entry_statuses].all.each do |status|
      statuses[status[:id]] = status[:name]
    end

    alter_table(:section_entries) do
      if Zen.database.adapter_scheme.to_s.include?('mysql')
        drop_constraint(:section_entries_ibfk_3, :type => :foreign_key)
      end

      drop_column(:section_entry_status_id)
      add_column(:status, String, :default => 'draft')
    end

    entries.each do |entry|
      Zen.database.filter(:id => entry[:id]) \
        .update(:status => statuses[entry[:section_entry_status_id]])
    end

    drop_table(:section_entry_statuses)
  end
end
