Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    Zen.database[:settings].filter(:name => 'website_enabled').delete 
  end
  
  # Reverts the changes made in the up() block.
  down do
    Zen.database[:settings].insert(
      :name => 'website_enabled', :group => 'general', :default => true, :type => 'radio'
    )
  end
end
