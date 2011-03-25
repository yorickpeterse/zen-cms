Sequel.extension(:migration)

module Zen
  module Task
    ##
    # The Theme task is used to install, delete and manage Zen themes.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    #
    class Theme < Thor
      namespace :theme

      desc('list', 'Lists all installed themes')

      ##
      # Lists all installed themes
      #
      # @author Yorick Peterse
      # @since  0.2.4
      #
      def list
        table = []
        table.push(['Name', 'Author', 'Identifier', 'Templates'])
        table.push(['------', '------', '------', '------'])

        Zen::Theme.themes.each do |ident, theme|
          table.push([theme.name, theme.author, theme.identifier, theme.template_dir])
        end

        print_table(table)
      end 

      desc('migrate', 'Migrates a theme to the given version')

      method_option(:version   , :type => :numeric, :default => nil)
      method_option(:identifier, :type => :string , :default => nil, :required => true)
     
      ##
      # Migrates a theme to the given version.
      #
      # @author Yorick Peterse
      # @since  0.2.4
      #
      def migrate
        version = options[:version]
        ident   = options[:identifier]
        
        if Zen::Theme.themes.nil? or Zen::Theme.themes.empty?
          abort "No themes have been loaded. Be sure to add them to config/requires.rb."
        end

        if version.nil?
          puts "No version specified with --version, choosing the most recent version..."
        end

        install_theme = Zen::Theme[ident]

        if ident.nil? or ident.empty?
          abort "You specified an invalid identifier."
        end

        # Get the directory from the migration_dir getter, generate it if it isn't there.
        if install_theme.respond_to?(:migration_dir) and !install_theme.migration_dir.nil?
          dir = install_theme.migration_dir
        else
          abort "The specified theme has no migrations directory"
        end

        table = install_theme.identifier.gsub('.', '_').to_sym
         
        puts "Migrating theme..."
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

