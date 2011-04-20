Sequel.extension(:migration)

module Zen
  module Task
    ##
    # The Package task is used to install, delete and manage Zen packages.
    #
    # @author Yorick Peterse
    # @since  0.2
    #
    class Package < Thor
      namespace :package

      desc('list', 'Lists all installed packages')

      ##
      # Lists all installed packages
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def list
        table = []
        table.push(['Name', 'Author', 'Identifier', 'Directory'])
        table.push(['------', '------', '------', '------'])

        Zen::Package.packages.each do |ident, ext|
          table.push([ext.name, ext.author, ext.identifier, ext.directory])
        end

        print_table(table)
      end 

      desc('migrate', 'Migrates a package to the given version')

      method_option(:version   , :type => :numeric, :default => nil)
      method_option(:identifier, :type => :string , :default => nil, :required => true)
     
      ##
      # Migrates a package to the given version.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def migrate
        version = options[:version]
        ident   = options[:identifier]
        
        if Zen::Package.packages.nil? 
          abort "No packages have been loaded. Be sure to add them to config/requires.rb."
        end

        if version.nil?
          puts "No version specified with --version, choosing the most recent version..."
        end

        install_ext = Zen::Package[ident]

        if ident.nil? or ident.empty? or install_ext.nil?
          abort "You specified an invalid identifier."
        end

        # Get the directory from the migration_dir getter, generate it if it isn't there.
        if install_ext.respond_to?(:migration_dir) and !install_ext.migration_dir.nil?
          dir = install_ext.migration_dir
        else
          dir = install_ext.directory + '/../../migrations'
        end

        table = install_ext.identifier.gsub('.', '_').to_sym
         
        puts "Migrating package..."
        if File.directory?(dir)
          Zen::Database.handle.transaction do
            Sequel::Migrator.run(Zen::Database.handle, dir, :table => table, :target => version)
            
            if version == 0
              # Remove the migrations table
              Zen::Database.handle.drop_table table
            end
          end
        end
      end

    end
  end
end
