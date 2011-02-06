Sequel.migration do

  up do
    create_table :sections do
      primary_key :id
      
      String    :name,                    :null => false
      String    :slug,                    :null => false, :unique => true
      String    :description,             :text => true
      TrueClass :comment_allow,           :null => false, :default => true
      TrueClass :comment_require_account, :null => false, :default => false
      TrueClass :comment_moderate,        :null => false, :default => false
      TrueClass :comment_antispam,        :null => false, :default => true
      Enum      :comment_format,          :elements => ['plain', 'html', 'textile', 'markdown'], :null => false, :default => 'plain'
    end
    
    create_table :section_entries do
      primary_key :id
      
      String  :title , :default => 'Untitled'
      String  :slug  , :null => false, :unique => true
      Enum    :status, :elements => ['published', 'draft'], :null => false, :default => 'draft'
      Time    :created_at
      Time    :updated_at
      
      foreign_key :section_id, :sections, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
  end
  
  down do
    drop_table :section_entries
    drop_table :sections
  end

end