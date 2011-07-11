require 'fileutils'

#:nodoc:
module Zen
  #:nodoc:
  module Bin
    ##
    # Command that can be used to create a new application prototype.
    #
    # ## Syntax
    #
    #     $ zen app [NAME]
    #
    # ## Usage
    #
    #     $ zen app blog
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class App
      ##
      # Hash containing options that can be overwritten via the command line.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      Options = {
        :force => false
      }

      ##
      # Creates a new instance of the class and specifies all the options.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def initialize
        @options = OptionParser.new do |opt|
          opt.banner         = 'Creates a new application prototype'
          opt.summary_indent = '  '

          opt.separator "
Usage:
  zen app [NAME] [OPTIONS]

Example:
  zen app blog

Options:
"

          opt.on('-h', '--help', 'Shows this help message') do
            puts @options
            exit
          end

          opt.on('-f', '--force', 'Overwrites existing directories') do
            Options[:force] = true
          end
        end
      end

      ##
      # Executes the command based on the specified command line arguments.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Array] argv An array containing all the additional options that
      # were specified in the command line.
      #
      def run(argv = [])
        @options.parse!(argv)

        app = argv.delete_at(0)

        # Show the help message if no application name has been specified
        if app.nil?
          puts @options
          exit
        end

        proto = __DIR__('../../../proto/app')
        
        if File.directory?(app) and Options[:force] === false
          $stderr.puts "The application #{app} already exists, use -f to " \
            + "overwrite it."
          exit
        else
          FileUtils.rm_rf(app)
        end

        # Copy the prototype
        begin
          FileUtils.cp_r(proto, app)
          puts "The application has been generated and saved in #{app}"
        rescue => e
          $stderr.puts "Failed to generate the application: #{e.message}"
          exit
        end
      end
    end # App
  end # Bin
end # Zen
