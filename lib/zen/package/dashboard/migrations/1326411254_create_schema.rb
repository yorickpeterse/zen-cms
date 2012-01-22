Sequel.migration do
  up do
    create_table :widgets do
      primary_key :id

      String  :name,  :null => false
      Integer :order, :null => false

      foreign_key :user_id, :users, :on_delete => :cascade,
        :on_update => :cascade, :key => :id
    end

    add_column :users, :widget_columns, Integer, :default => 1

    rows = []

    Zen.database[:users].select(:id).each do |user|
      rows << {:user_id => user[:id], :order => 0, :name => 'welcome'}
    end

    Zen.database[:widgets].multi_insert(rows)
  end

  down do
    drop_table  :widgets
    drop_column :users, :widget_columns
  end
end
