require 'fileutils'
require 'ruby-extensions'

module Zen
  module Task
    ##
    # The Proto task can be used to create migrations, packages and full blown applications.
    #
    # @author Yorick Peterse
    # @since  0.2
    #
    class Proto < Thor
      namespace :proto

      desc 'migration', 'Creates a new migration'
      method_option :directory, :type => :string, :required => true

      ##
      # Creates a new (blank) migration.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def migration
        dir        = options[:directory]
        proto_path = File.expand_path('../../../../proto/migration.rb', __FILE__)
      
        # Get the name
        name = ask("Migration name:")
        
        # If no directory is specified we'll store the migrations under ./migrations
        if dir.nil? or dir == ''
          if !File.directory?('./migrations')
            abort "No directory specified and ./migrations doesn't exist"
          else  
            dir = './migrations'
            puts "Using ./migrations"
          end
        else  
          puts "Using #{dir}"
        end
        
        # Generate the prototype
        puts "Generating..."
        
        proto = File.open(proto_path, 'r').read
        path  = "#{dir}/#{Time.new.to_i}_#{name}.rb"
        
        begin
          File.open(path, 'w').write(proto)
          puts "Done!"
        rescue => e
          puts "Failed to generate the migration: #{e}"
        end
      end

      desc 'package', 'Creates a new package'
      method_option :directory, :type => :string, :required => true

      ##
      # Creates a new package.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def package
        name           = ask("Package name:").strip.downcase.gsub(' ', '_')
        proto          = File.expand_path('../../../../proto/package', __FILE__)
        klass          = name.camel_case
        extension_path = options[:directory] + '/' + name
        
        FileUtils.rm_rf(extension_path)
        
        # Rename all files and folders
        begin
          FileUtils.cp_r(proto, extension_path)
          
          lib_path = "#{extension_path}/lib/#{name}"
          
          # Rename the base file and directory
          FileUtils.mv("#{extension_path}/lib/package"   , lib_path)
          FileUtils.mv("#{extension_path}/lib/package.rb", "#{extension_path}/lib/#{name}.rb")
          
          # ------------------------------------------------
          
          controller_filename = klass.snake_case.pluralize
          model_filename      = klass.snake_case.singularize
          
          # Generate the controller
          controller = File.open("#{lib_path}/controller/controllers.rb", 'r').read
          controller.gsub!('CONTROLLER', klass.pluralize)
          controller.gsub!('EXTENSION' , klass.pluralize)
          
          FileUtils.mv("#{lib_path}/controller/controllers.rb", "#{lib_path}/controller/#{controller_filename}.rb")
          File.open("#{lib_path}/controller/#{controller_filename}.rb", 'w').write(controller)

          # Move the view directory
          FileUtils.mv("#{lib_path}/view/admin/package", "#{lib_path}/view/admin/#{controller_filename}")
          
          # Generate the model
          model = File.open("#{lib_path}/model/model.rb", 'r').read
          model.gsub!('MODEL'     , klass.singularize)
          model.gsub!('EXTENSION' , klass.pluralize)
          
          FileUtils.mv("#{lib_path}/model/model.rb", "#{lib_path}/model/#{model_filename}.rb")
          File.open("#{lib_path}/model/#{model_filename}.rb", 'w').write(model)
          
          puts "Done! Don't forget to rename the controllers/models/etc"
        rescue => e
          abort "Failed to generate the extesion: #{e}"
        end
      end

    end
  end
end
