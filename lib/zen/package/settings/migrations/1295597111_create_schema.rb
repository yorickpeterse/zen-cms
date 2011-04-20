Sequel.migration do

  up do
    create_table :settings do
      primary_key :id
      
      String :key      , :null => false, :unique => true
      String :group_key, :null => false
      String :default  , :text => true
      String :type     , :default => 'textbox' 
      String :value    , :text => true
    end
  end
  
  down do
    drop_table :settings
  end

end
