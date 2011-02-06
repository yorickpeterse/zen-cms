require 'fileutils'

module Zen
  module Bin
    ##
    # Main binary class that contains a few methods that can be used
    # to generate new applications, extensions and so on.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Base < Thor
      
      map ["-v", "--version"] => :version
      
      # ------------------------------------------------
      
      desc "app [NAME]", "Creates a new Zen application"
      method_option :force, :type => :boolean, :aliases => "-f",
        :desc => "Overwrites any existing directories"
      
      ##
      # Creates a new Zen application using a prototype extracted from the
      # Rubygem package.
      #
      # @author Yorick Peterse
      # @param  [String] name The name of the new application
      # @since  0.1
      #
      def app name
        # Do we have an application name?
        if name.nil?
          abort "You need to specify a name for your application"
        end
        
        app   = './' + name
        proto = __DIR__('../../../proto/app')
        
        if File.directory?(app) and !options.force?
          abort "Application already exists, use -f to overwrite it"
        else
          FileUtils.rm_rf(app)
        end
        
        # Copy the prototype
        begin
          FileUtils.cp_r(proto, app)
        
          puts "Application generated, now do the following:
1. edit the following configuration files:
  * config/database.rb
  * config/config.rb
2. run rake db:migrate to install all extensions and create a default user
3. have fun!"
        rescue => e
          abort "Failed to generate the application: #{e}"
        end
      end
      
      # ------------------------------------------------
      
      desc "extension [NAME]", "Creates a new Zen extension"
      method_option :force, :type => :boolean, :aliases => "-f",
        :desc => "Overwrites any existing directories"
      
      ##
      # Creates a new Zen extension for the given name.
      #
      # @author Yorick Peterse
      # @param  [String] name The name of the extension
      # @since  0.1
      #
      def extension name
        name  = name.strip.downcase.gsub(' ', '_')
        proto = __DIR__('../../../proto/module')
        klass = name.camel_case
        
        if name.nil?
          abort "You need to specify an extension name"
        end
        
        extension_path = "./#{name}"
        
        if File.directory?(extension_path) and !options.force?
          abort "Extension already exists, use -f to overwrite it"
        else
          FileUtils.rm_rf(extension_path)
        end
        
        # Rename all files and folders
        begin
          FileUtils.cp_r(proto, extension_path)
          
          lib_path = "#{extension_path}/lib/#{name}"
          
          # Rename the base file and directory
          FileUtils.mv("#{extension_path}/lib/module"   , lib_path)
          FileUtils.mv("#{extension_path}/lib/module.rb", "#{extension_path}/lib/#{name}.rb")
          
          # ------------------------------------------------
          
          controller_filename = klass.snake_case.pluralize
          model_filename      = klass.snake_case.singularize
          
          # Generate the controller
          controller = File.open("#{lib_path}/controller/controllers.rb", 'r').read
          controller.gsub!('CONTROLLER', klass.pluralize)
          controller.gsub!('EXTENSION' , klass.pluralize)
          
          FileUtils.mv("#{lib_path}/controller/controllers.rb", "#{lib_path}/controller/#{controller_filename}.rb")
          File.open("#{lib_path}/controller/#{controller_filename}.rb", 'w').write(controller)
          
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
      
      # ------------------------------------------------
      
      desc "version", "Shows the current version of Zen"
      
      ##
      # Shows the current version of Zen
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def version
        puts "Zen v#{Zen::Version}"
      end
      
      # ------------------------------------------------
      
      ##
      # Override the help method provided by Thor
      # so we can show our custom banner.
      #
      # @author Yorick Peterse
      # @see    Thor.help()
      # @since  0.1
      # 
      def help task = nil, subcommand = false
        if task.nil?
          puts "Zen is a modular CMS written using Ramaze.

Usage:
  $ zen [command] [arguments] [flags]

Example:
  $ zen app blog

Project Details:
  * website: http://ruby-zen.org/
  * github: https://github.com/rubyzen/
  * version: v#{Zen::Version}

"
        end
        
        super(task, subcommand)
      end
    end
  end
end