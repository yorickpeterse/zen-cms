# Database configuration
Zen::Database.mode :dev do |db|
  db.adapter  = ''
  db.host     = ''

  db.username = ''
  db.password = ''
  db.database = ''
end

Zen::Database.mode :live do |db|
  db.adapter  = ''
  db.host     = ''

  db.username = ''
  db.password = ''
  db.database = ''
end