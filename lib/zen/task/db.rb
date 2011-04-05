Sequel.extension(:migration)

module Zen
  module Task
    ##
    # Task that can be used for various database related operations such as creating
    # a default user and migrating the entire database.
    #
    # @author Yorick Peterse
    # @since  0.2
    #
    class DB < Thor
      namespace :db

      desc('migrate', 'Migrates the entire database to the latest version')

      ##
      # Migrates the entire database to the latest version.
      #
      # @author Yorick Peterse
      # @param  [Boolean] show_output When set to false no output will be shown.
      # @since  0.2
      #
      def migrate(show_output = true)
        exts = Zen::Package.packages

        puts "Migrating..." if show_output === true

        exts.each do |ident, ext|
          if ext.respond_to?(:migration_dir) and !ext.migration_dir.nil?
            dir = ext.migration_dir
          else
            dir = ext.directory + '/../../migrations'
          end
          
          table = ext.identifier.gsub('.', '_').to_sym
            
          if File.directory?(dir)
            Zen::Database.handle.transaction do
              Sequel::Migrator.run(Zen::Database.handle, dir, :table => table)
            
              puts "Successfully migrated \"#{ext.name}\"" if show_output === true
            end
          end
        end
      end

      desc('delete', 'Deletes all database tables')

      ##
      # Deletes all database tables.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def delete
        exts = Zen::Package.packages.map { |ident, ext| [ident, ext] }

        exts.reverse.each do |ident, ext|
          if ext.respond_to?(:migration_dir) and !ext.migration_dir.nil?
            dir = ext.migration_dir
          else
            dir = ext.directory + '/../../migrations'
          end

          table = ext.identifier.gsub('.', '_').to_sym
            
          if File.directory?(dir)
            Zen::Database.handle.transaction do
              puts "Uninstalling \"#{ext.name}\""
              
              Sequel::Migrator.run(Zen::Database.handle, dir, :table => table, :target => 0)
              
              # Remove the migrations table
              Zen::Database.handle.drop_table table
            end
          end
        end
      end

      desc('user', 'Creates a default administrator account')

      ##
      # Creates a default administrator account.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def user
        password = (0..12).map do
          letter = ('a'..'z').to_a[rand(26)]
          number = (0..9).to_a[rand(26)]
          
          letter + number.to_s
        end.join
      
        # Only insert the user if it isn't there yet.
        user  = Users::Model::User[:email => 'admin@website.tld']
        group = Users::Model::UserGroup[:slug => 'administrators']
        
        if group.nil?
          group = Users::Model::UserGroup.new(
            :name => 'Administrators',
            :slug => 'administrators', :super_group => true
          ).save
        end
        
        if !user.nil?
          abort "The default user has already been inserted."
        end
        
        user = Users::Model::User.new(
          :email => 'admin@website.tld', :name => 'Administrator',
          :password => password, :status => 'open'
        ).save
        
        user.user_group_pks = [group.id]
        
        puts "Default administrator account has been created.

Email: admin@website.tld
Passowrd: #{password}

You can login by going to http://domain.tld/admin/users/login/
"

      end
    end
  end
end
