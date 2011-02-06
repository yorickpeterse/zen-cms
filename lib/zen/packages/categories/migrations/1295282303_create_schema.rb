Sequel.migration do

  up do
    create_table :category_groups do
      primary_key :id
      
      String :name,        :null => false
      String :description, :text => true
    end
    
    create_table :categories do
      primary_key :id
      
      Integer :parent_id,             :index => true
      String  :name,                  :null => false
      String  :description,           :text => true
      String  :slug,                  :null => false,   :unique => true
      
      foreign_key :category_group_id, :category_groups, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
    
    create_table :categories_section_entries do      
      foreign_key :section_entry_id, :section_entries, :on_delete => :cascade, :on_update => :cascade, :key => :id
      foreign_key :category_id,      :categories,      :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
    
    create_table :category_groups_sections do
      foreign_key :section_id,        :sections,        :on_delete => :cascade, :on_update => :cascade, :key => :id
      foreign_key :category_group_id, :category_groups, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
  end
  
  down do
    drop_table :category_groups_sections
    drop_table :categories_section_entries
    drop_table :categories
    drop_table :category_groups
  end

end