##
# Database group to use for developing the website.
#
# The following options can be set:
#
# * adapter: the SQL adapter used by Sequel to connect to the database. Examples of these
# are mysql2, postgres, sqlite, etc.
# * host: the hostname of the database server.
# * username: the name of the user used for connecting to the database
# * password: the password of the user used for connecting to the database.
# * database: the name of the database to use.
#
# IMPORTANT: it's recommended to create a database user for your Zen application and
# prevent it from being able to access other databases. Zen is new and may allow hackers
# to exploit the system. Using an isolated user would prevent hackers from destroying
# all databases.
#
Zen::Database.mode :dev do |db|
  # Example: mysql2
  db.adapter  = ''

  # Example: localhost
  db.host     = ''

  # Example: zen-app
  db.username = ''
  
  # Example: 23x190jj38123x
  db.password = ''

  # Example: blog
  db.database = ''
end

##
# Database group to use for your production server.
# This group accepts the same settings as the block above.
#
Zen::Database.mode :live do |db|
  # Example: mysql2
  db.adapter  = ''

  # Example: localhost
  db.host     = ''

  # Example: zen-app
  db.username = ''
  
  # Example: 23x190jj38123x
  db.password = ''

  # Example: blog
  db.database = ''
end
