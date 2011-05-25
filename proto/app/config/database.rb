##
# Database group to use for developing the website.
#
# IMPORTANT: it's recommended to create a separate database user for your Zen application 
# and prevent it from being able to access other databases. Zen is new and may allow 
# hackers to exploit the system.
#
# The following items can be set:
#
# * adapter: the adapter to use. When using MySQL it's best to use the mysql2 gem as it's 
#   a lot faster than the mysql gem.
# * host: the hostname where the database is located.
# * username: the username to use for connecting to the database.
# * password: the password to use for connecting to the database.
# * database: the name of the database to use.
# * test: whether or not the connection should be verified.
# * encoding: the encoding type to use.
# * logger: the logger used for logging queries and such.
#
# Fore more information see the Sequel documentation: 
# http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html
#
# Sets the connection for the development mode
if Ramaze.options.mode === :dev
  Zen.database = Sequel.connect(
    :adapter  => '',
    :host     => 'localhost',
    :username => '',
    :password => '',
    :database => '',
    :test     => true,
    :encoding => 'utf8',
    :logger   => Ramaze::Logger::RotatingInformer.new(
      __DIR__("../log/database/dev"), '%d-%m-%Y.log'
    )
  )

# Does the same but for the live mode
elsif Ramaze.options.mode === :live
  Zen.database = Sequel.connect(
    :adapter  => 'mysql2',
    :host     => '',
    :username => '',
    :password => '',
    :database => '',
    :test     => true,
    :encoding => 'utf8',
    :logger   => Ramaze::Logger::RotatingInformer.new(
      __DIR__("../log/database/live"), '%d-%m-%Y.log'
    )
  )
end

# IMPORTANT, when running MySQL the engine should be set to InnoDB in order for foreign 
# keys to work properly.
if Zen.database.adapter_scheme.to_s.include?('mysql')
  Sequel::MySQL.default_engine = 'InnoDB'
end
