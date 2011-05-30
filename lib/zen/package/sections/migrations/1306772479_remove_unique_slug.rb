Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    entries = Zen.database[:section_entries].all

    drop_column(:section_entries, :slug)
    add_column(:section_entries , :slug, String)
    add_index(:section_entries  , :slug)

    entries.each do |entry|
      Zen.database[:section_entries] \
        .filter(:id => entry[:id]).update(:slug => entry[:slug])
    end
  end
  
  # Reverts the changes made in the up() block.
  down do
    entries = Zen.database[:section_entries].all

    drop_column(:section_entries, :slug)
    add_column(:section_entries, :slug, String, :unique => true)

    entries.each do |entry|
      Zen.database[:section_entries] \
        .filter(:id => entry[:id]).update(:slug => entry[:slug])
    end    
  end
end
