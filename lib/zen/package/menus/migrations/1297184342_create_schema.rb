Sequel.migration do

  up do
    create_table :menus do
      primary_key :id

      String :name        , :null => false
      String :slug        , :null => false, :index => true
      String :description , :text => true
      String :css_class
      String :css_id
    end

    create_table :menu_items do
      primary_key :id

      Integer :parent_id, :index   => true
      String  :name     , :null    => false
      String  :url      , :null    => false
      Integer :order    , :default => 0
      String  :css_class
      String  :css_id

      foreign_key :menu_id, :menus, :update => :on_cascade, :on_delete => :cascade, :key => :id
    end
  end

  down do
    drop_table :menu_items
    drop_table :menus
  end

end
