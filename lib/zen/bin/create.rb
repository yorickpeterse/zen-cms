require 'readline'
require 'erb'
require 'fileutils'

module Zen
  module Bin
    ##
    # Command that can be used to create new Zen projects.
    #
    # @since 0.3
    #
    class Create < Shebang::Command
      command :create
      banner  'Creates a new Zen project'
      usage   'zen create [OPTIONS]'

      o :l, :lazy , 'Creates a new project with all default options'
      o :f, :force, 'Overwrite existing directories when creating a project'

      # Path to the prototype application to use for new projects.
      Prototype = __DIR__('../../../proto/app')

      # Hash containing various Rack servers and their default configuration
      # files to use.
      ServerConfigs = {
        :unicorn => __DIR__('../../../proto/rack/unicorn.rb'),
        :thin    => __DIR__('../../../proto/rack/thin.yml')
      }

      # Hash containing the options to use for creating a new project.
      ProjectSettings = {
        :name      => 'zen_project',
        :database  => {
          :adapter  => 'sqlite',
          :database => 'database.db',
          :username => nil,
          :password => nil
        },
        :server_config => nil
      }

      ##
      # Method that is called when this command is invoked without any
      # additional parameters.
      #
      # @since 0.3
      #
      def index
        if option(:l)
          create_project
          return
        end

        intro
        setup_name
        database_settings
        server_config

        create_project
      end

      private

      ##
      # Displays a short introduction to the installer.
      #
      # @since 0.3
      #
      def intro
        puts wrap_string(
          'Welcome to the interactive project creator of Zen. ' \
          'This installer will guide you through the process of creating ' \
          'a new project using Zen.'
        )

        puts
        puts wrap_string(
          'Keep in mind that all settings specified for each project can be ' \
            'changed to anything you like. Zen tries to make as little ' \
            'assumptions as possible.'
        )
      end

      ##
      # Sets the name of the project.
      #
      # @since 0.3
      #
      def setup_name
        heading('Project Name')

        puts wrap_string(
          'Each Zen project requires a name. This name is used for the ' \
            'directory name as well as the session ID.'
        )

        name = readline('Name of your project', ProjectSettings[:name])
        name = name.downcase.gsub(/\s+/, '_')

        ProjectSettings[:name] = name unless name.empty?
      end

      ##
      # Asks the user for various database settings.
      #
      # @since 0.3
      #
      def database_settings
        heading('Database Settings')

        puts wrap_string(
          'Zen stores it\'s data in a SQL database such as PostgreSQL or ' \
          'MySQL. In order to connect to such a database you must specify ' \
          'the connection details such as the username and database name.'
        )

        ProjectSettings[:database][:adapter] = readline(
          'Adapter',
          ProjectSettings[:database][:adapter]
        )

        ProjectSettings[:database][:database] = readline(
          'Database',
          ProjectSettings[:database][:database],
          false
        )

        ProjectSettings[:database][:username] = readline('Username', nil, false)
        ProjectSettings[:database][:password] = readline('Password', nil, false)
      end

      ##
      # Asks the user if he/she would like to use a default configuration file
      # for Unicorn or Thin.
      #
      # @since 0.3
      #
      def server_config
        heading('Server Configuration')

        puts wrap_string(
          'Zen comes with a few default configuration files that you can use ' \
            'for your favorite Rack server. Zen supports the following servers:'
        )

        puts

        ServerConfigs.each do |name, path|
          puts "* #{name}"
        end

        puts
        puts wrap_string(
          'If you are using a different server or simply don\'t want a ' \
            'default configuration file you can choose "none".'
        )

        server = readline('Default server configuration file', 'none').downcase

        if !server.empty? and server != 'none' \
        and !ServerConfigs.keys.include?(server.to_sym)
          error('The specified configuration file is invalid')
        end

        ProjectSettings[:server_config] = server.to_sym unless server == 'none'
      end

      ##
      # Creates a new project based on the settings specified by the user.
      #
      # @since 0.3
      #
      def create_project
        destination = File.join(Dir.pwd, ProjectSettings[:name])

        # Copy the application
        if File.directory?(destination) and !option(:f)
          error('There already is a directory using your project name')
        else
          puts 'Creating base files...'

          FileUtils.rm_rf(destination)
          FileUtils.cp_r(Prototype, destination)
        end

        # Copy the default Rack configuration file.
        if !ProjectSettings[:server_config].nil? \
        and !ProjectSettings[:server_config].empty?
          puts 'Creating server configuration file...'

          config = ServerConfigs[ProjectSettings[:server_config]]

          FileUtils.cp(
            config,
            File.join(destination, 'config', File.basename(config))
          )
        end

        # Replace all the ERB tags
        puts 'Setting variables...'

        templates = Dir.glob(File.join(destination, '**', '*.erb'))

        templates.each do |template|
          processed = File.read(template, File.size(template))
          processed = ERB.new(processed).result(binding)

          File.open(template, 'w') do |handle|
            handle.write(processed)
          end

          # Remove the .erb extension
          FileUtils.mv(
            template,
            File.join(File.dirname(template), File.basename(template, '.erb'))
          )
        end

        puts wrap_string(
          "Your project has been created, you can find it in #{destination}"
        )
      end

      ##
      # Wraps a string at 80 characters and returns it.
      #
      # @since  0.3
      # @param  [String] input The string to wrap.
      # @return [String]
      #
      def wrap_string(input)
        input  = input.split(/\s+/)
        output = ''
        chars  = 0

        input.each do |chunk|
          length = chunk.length

          if ( chars + length ) <= ( 80 - length )
            output += "#{chunk} "
            chars  += length
          else
            output += "\n#{chunk} "
            chars   = 0
          end
        end

        return output.strip
      end

      ##
      # Displays a heading in yellow.
      #
      # @since 0.3
      # @param [String] heading The heading to display.
      #
      def heading(heading)
        puts "\n" + heading.yellow + "\n\n"
      end

      ##
      # Shows a prompt using Readline.readline and returns the value entered by
      # the user.
      #
      # @since  0.3
      # @param  [String] message The message to display in the prompt.
      # @param  [String] default The default value to use.
      # @param  [TrueClass|FalseClass] newline When set to true an empty line
      #  will be shown before the prompt.
      # @return [String]
      #
      def readline(message, default = nil, newline = true)
        puts if newline

        prompt = "> #{message}"

        if default
          prompt += " (default: #{default})"
        end

        prompt += ': '
        value   = Readline.readline(prompt.blue).strip

        if value.empty? and !default.nil?
          value = default
        end

        return value
      end

      ##
      # Shows an error and exists the script.
      #
      # @since 0.3
      # @param [String] message The error message to display.
      #
      def error(message)
        puts message.red
        exit(false)
      end
    end # Create
  end # Bin
end # Zen
