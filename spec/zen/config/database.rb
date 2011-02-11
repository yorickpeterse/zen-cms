Zen::Database.mode :spec do |db|
  db.adapter  = 'sqlite'
  db.host     = ''

  db.username = ''
  db.password = ''
  db.database = __DIR__('../spec_database.db')
end
