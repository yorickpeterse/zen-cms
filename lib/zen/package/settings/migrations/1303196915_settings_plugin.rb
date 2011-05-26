Sequel.migration do

  up do
    rename_column(:settings, :key, :name, :unique => true)
    rename_column(:settings, :group_key, :group)

    drop_column(:settings, :language_key)
    drop_column(:settings, :language_group_key)

    # Update the settings
    Zen.database[:settings].all.each do |row|
      name  = row[:name].split('.').last
      group = row[:group].split('.').last

      Zen.database[:settings].filter(:id => row[:id]) \
        .update(:name => name, :group => group)
    end
  end
  
  down do
    rename_column(:settings, :name , :key)
    rename_column(:settings, :group, :group_key)

    add_column(:settings, :language_key      , String)
    add_column(:settings, :language_group_key, String)
  end

end
