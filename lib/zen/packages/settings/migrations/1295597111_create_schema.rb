Sequel.migration do

  up do
    create_table :settings do
      primary_key :id
      
      String :key      , :null => false, :unique => true
      String :group_key, :null => false
      String :default  , :text => true
      Enum   :type     , :elements => ['textbox', 'textarea', 'radio', 'checkbox', 'select']
      String :value    , :text => true
    end
    
    # Insert our default settings
    Zen::Database.handle[:settings].insert_multiple([
      {:key => 'website_name'       , :group_key => 'general' , :default => 'Zen', :type => 'textbox'},
      {:key => 'website_description', :group_key => 'general' ,                    :type => 'textarea'},
      {:key => 'website_enabled'    , :group_key => 'general' , :default => '1',   :type => 'radio'},
      {:key => 'language'           , :group_key => 'general' , :default => 'en',  :type => 'select'},
      {:key => 'default_section'    , :group_key => 'general' ,                    :type => 'select'},
      {:key => 'theme'              , :group_key => 'general' ,                    :type => 'select'},
      {:key => 'enable_antispam'    , :group_key => 'security', :default => true,  :type => 'radio'},
      {:key => 'defensio_key'       , :group_key => 'security',                    :type => 'textbox'}
    ])
  end
  
  down do
    drop_table :settings
  end

end