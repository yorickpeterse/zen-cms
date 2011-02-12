Sequel.migration do

  up do
    create_table :users do
      primary_key :id
        
      String :email,    :null      => false, :unique => true
      String :name
      String :website
      String :password, :null      => false
      String :status,   :default => 'closed'
      Time   :created_at
      Time   :updated_at
      Time   :last_login
    end
    
    create_table :user_groups do
      primary_key :id
      
      String :name, :null => false
      String :slug, :null => false, :unique => true
      String :description, :text => true
      TrueClass :super_group, :default => false, :null => false
    end
    
    create_table :user_groups_users do
      foreign_key :user_id, :users, :on_delete => :cascade, :on_update => :cascade, :key => :id
      foreign_key :user_group_id, :user_groups, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
    
    create_table :access_rules do
      primary_key :id
      
      String    :extension,         :null => false
      
      TrueClass :read_access,       :default => true,  :null => false
      TrueClass :create_access,     :default => false, :null => false
      TrueClass :update_access,     :default => false, :null => false
      TrueClass :delete_access,     :default => false, :null => false
      
      # Not using real foreign keys as they can't be empty
      Integer :user_id
      Integer :user_group_id
    end
  end
  
  down do
    drop_table :access_rules
    drop_table :user_groups_users
    drop_table :user_groups
    drop_table :users
  end

end
