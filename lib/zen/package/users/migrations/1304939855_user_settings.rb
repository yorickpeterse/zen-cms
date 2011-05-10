Sequel.migration do

  up do
    add_column(:users, :language         , String, :default => 'en')
    add_column(:users, :frontend_language, String, :default => 'en')
    add_column(:users, :date_format      , String, :default => '%Y-%m-%d %H:%I:%S') 
  end
  
  down do
    drop_column(:users, :language)
    drop_column(:users, :date_format)
    drop_column(:users, :frontend_language)
  end

end
