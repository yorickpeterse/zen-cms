# Load all commands
require __DIR__('app')

#:nodoc:
module Zen
  #:nodoc:
  module Bin
    ##
    # Module used to set various global options for the command line utility and
    # run a command based on the specified parameters.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    module Runner
      ##
      # Hash containing all the available commands and their class names.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      Commands = {
        :app => Zen::Bin::App
      }

      ##
      # Runs a command based on the command line arguments or a specified array
      # to use instead of ARGV.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Array] argv An array containing command line arguments.
      #
      def self.run(argv=ARGV)
        op = OptionParser.new do |opt|
          opt.banner         = 'Zen is a modular CMS written using Ramaze'
          opt.summary_indent = '  '

          opt.separator "
Usage:
  zen [COMMAND] [OPTIONS]

Available Commands:
  app: Creates a new application prototype

Options:
"

          # Define the available options
          opt.on('-v', '--version', 'Shows the version of Zen') do
            puts Zen::Version
            exit
          end

          opt.on('-h', '--help', 'Shows this help message') do
            puts op
            exit
          end
        end

        # Parse it
        op.order!(argv)

        # Show the help message if no command has been specified
        if !argv[0]
          puts op
          exit
        end

        # Run the command if it exists
        cmd = argv.delete_at(0).to_sym

        if Commands.key?(cmd)
          cmd = Commands[cmd].new
          cmd.run(argv)
        else
          $stderr.puts "The specified command is invalid"
          exit
        end
      end
    end # Runner
  end # Bin
end # Zen
