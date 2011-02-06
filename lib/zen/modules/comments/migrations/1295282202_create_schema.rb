Sequel.migration do

  up do
    create_table :comments do
      primary_key :id
     
      Integer :user_id
      String  :name
      String  :website
      String  :email
      String  :comment,    :text => true
      Enum    :status,     :elements => ['open', 'closed', 'spam'], :default => 'closed'
      Time    :created_at
      Time    :updated_at
      
      foreign_key :section_entry_id, :section_entries, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
  end
  
  down do
    drop_table :comments
  end

end