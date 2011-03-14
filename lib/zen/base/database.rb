#:nodoc:
module Zen
  ##
  # The database module is one of the most important classes in Zen (which is quite obvious).
  # Without this module the application wouldn't exist. The database module is 
  # basically a small wrapper around the Sequel.connect method and allows developers 
  # to specify database settings for various environments (live, test, production, etc) 
  # using a simple block.
  #
  # ## Database Configuration
  #
  # Connecting to a database is fairly easy and only requires a single configuration file.
  # In this file, called "database.rb" you'll define all your database environments 
  # (live, dev, test, etc).
  # 
  #     Zen::Database.mode :dev do |db|
  #       db.adapter  = 'mysql'
  #       db.host     = 'localhost'
  #
  #       db.username = 'root'
  #       db.password = 'root'
  #       db.database = 'database'
  #     end
  #
  # In this example we're connecting to "localhost" using the mysql adapter and 
  # selecting the database called "database". When placing multiple environments in the 
  # same file you don't have to worry about them overriding eachother, Zen will only 
  # load the environment settings of the block that matches
  # the current environment set in Ramaze.options.mode.
  #
  # ## Database Interaction
  #
  # Once your database configuration file has been loaded you can communicate with the 
  # database using  models. Each model should extend the base model provided by Sequel:
  #
  #     class Comment < Sequel::Model
  #     
  #     end
  #
  # Models can be called like any other class and don't need to be initialized. For 
  # more information on how to use models using Sequel you should read Sequel's 
  # documentation: http://sequel.rubyforge.com/
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  module Database
    include Innate::Optioned
    
    class << self
      attr_reader :handle  
    end
    
    # Database related configuration options
    options.dsl do
      o 'The database adapter to use.',   :adapter,    ''
      o 'The address of the SQL server.', :host,       ''
      o 'The database username',          :username,   ''
      o 'The database password',          :password,   ''
      o 'The database name',              :database,   ''
    end
    
    ##
    # Initializes a new database connection based on the configuration options specified in
    # Zen::Database.options. Sequel will trigger an error in case any of these settings
    # are incorrect. For logging a custom logger will be used, this logger can be found in
    # Zen::Logger().
    #
    # An extra notice for MySQL users, Zen uses InnoDB in order to use true foreign keys.
    # Make sure that your MySQL installation comes with the InnoDB plugin.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def self.init
      @handle = Sequel.connect(
        :adapter  => self.options.adapter,  
        :host     => self.options.host,     
        :database => self.options.database, 
        :username => self.options.username, 
        :password => self.options.password, 
        :logger   => Zen::Logger.new("#{Zen.options.root}/log/database"),
        :test     => true, 
        :encoding => Zen.options.encoding)
      
      # We'll need to use InnoDB for MySQL tables in order to provide proper foreign key support
      if self.options.adapter === 'mysql' or self.options.adapter === 'mysql2'
        Sequel::MySQL.default_engine = 'InnoDB'
      end
    end
    
    ##
    # Method that's used to provide the ability to use different database configurations 
    # for each mode. This method basically just sets the Zen.options.db parameters based 
    # on the provided variables in the block. If you don't want to use different database 
    # configurations you can just set the variables directly using Zen.options.db.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Symbol] mode The development mode for which the database settings should be used.
    # @param  [Block] &block Block containing all database settings.
    #
    def self.mode mode, &block
      mode = mode.to_sym
      
      if mode == Ramaze.options.mode
        yield self.options
      end
    end
  end
end
