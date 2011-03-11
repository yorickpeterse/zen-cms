require 'fileutils'
require 'ruby-extensions'
require File.expand_path('', __FILE__)

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
      def app(name)
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
      def help(task = nil, subcommand = false)
        if task.nil?
          puts "Zen is a modular CMS written using Ramaze.

Usage:
  $ zen [command] [arguments] [flags]

Example:
  $ zen app blog

Project Details:
  * website: http://zen-cms.com/
  * github: https://github.com/zen-cms/
  * version: v#{Zen::Version}

"
        end
        
        super(task, subcommand)
      end
    end
  end
end
