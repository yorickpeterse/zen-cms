Sequel.migration do

  up do
    alter_table :section_entries do
      add_column :user_id, Integer
      add_foreign_key [:user_id], :users, :on_delete => :cascade,
        :on_update => :cascade, :key => :id, :name => 'fk_section_entries_user_id'
    end
  end
  
  down do
    #alter_table :section_entries do
    #  drop_constraint 'fk_section_entries_user_id'
    #  drop_column :user_id
    #end
  end

end