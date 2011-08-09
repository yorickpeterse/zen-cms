require 'fileutils'

#:nodoc:
module Zen
  #:nodoc:
  module Bin
    ##
    # Command that can be used to create a new application prototype.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class Create
      # The description of this command.
      Description = 'Creates a new application prototype.'

      # The banner of this application.
      Banner = <<-TXT.strip
Creates a new application prototype and saves it in the given path.

Usage:
  zen create [NAME] [OPTIONS]

Example:
  zen create blog
      TXT

      # Hash containing options that can be overwritten via the command line.
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
        @stop    = false
        @options = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nOptions:\n"

          opt.on('-h', '--help', 'Shows this help message') do
            puts @options

            @stop = true
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
      #  were specified in the command line.
      #
      def run(argv = [])
        @options.parse!(argv)

        app = argv.delete_at(0)

        return if @stop === true
        return puts @options if app.nil?

        proto = __DIR__('../../../proto/app')

        if File.directory?(app) and Options[:force] === false
          return $stderr.puts "The application #{app} already exists, use -f " \
            + "to overwrite it."
        else
          FileUtils.rm_rf(app)
        end

        # Copy the prototype
        begin
          FileUtils.cp_r(proto, app)
          puts "The application has been generated and saved in #{app}"
        rescue => e
          return $stderr.puts "Failed to generate the application: #{e.message}"
        end
      end
    end # App
  end # Bin
end # Zen
