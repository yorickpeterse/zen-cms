# Load all commands
require __DIR__('create')

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
      # Hash containing all the available commands and their class names.
      Commands = {
        :create => Zen::Bin::Create
      }

      # The banner of this command.
      Banner = <<-TXT.strip
Zen is a modular CMS written on top of the awesome Ramaze framework.

Usage:
  zen [COMMAND] [OPTIONS]

Example:
  zen create blog
      TXT

      ##
      # Runs a command based on the command line arguments or a specified array
      # to use instead of ARGV.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Array] argv An array containing command line arguments.
      #
      def self.run(argv=ARGV)
        stop = false
        op   = OptionParser.new do |opt|
          opt.banner         = Banner
          opt.summary_indent = '  '

          opt.separator "\nCommands:\n  #{commands_info.join("\n  ")}"
          opt.separator "\nOptions:\n"

          # Define the available options
          opt.on('-v', '--version', 'Shows the version of Zen') do
            puts Zen::Version

            stop = true
          end

          opt.on('-h', '--help', 'Shows this help message') do
            puts op

            stop = true
          end
        end

        # Parse it
        op.order!(argv)

        # exit() doesn't work for specs.
        return if stop === true
        return puts op if !argv[0]

        # Run the command if it exists
        cmd = argv.delete_at(0).to_sym

        if Commands.key?(cmd)
          cmd = Commands[cmd].new
          cmd.run(argv)
        else
          return $stderr.puts "The specified command is invalid"
        end
      end

      ##
      # Generates an array of "rows" where each row contains the name and
      # description of a command. The descriptions of all commands are aligned
      # based on the length of the longest command name.
      #
      # This method has been ported from Ramaze.
      #
      # @author Yorick Peterse
      # @since  23-07-2011
      # @return [Array]
      #
      def self.commands_info
        cmds    = []
        longest = Commands.map { |name, klass| name.to_s }.sort[0].size

        Commands.each do |name, klass|
          name = name.to_s
          desc = ''

          # Try to extract the command description
          if klass.respond_to?(:const_defined?) \
          and klass.const_defined?(:Description)
            desc = klass.const_get(:Description)
          end

          # Align the description based on the length of the name
          while name.size <= longest do
            name += ' '
          end

          cmds.push(["#{name}    #{desc}"])
        end

        return cmds
      end
    end # Runner
  end # Bin
end # Zen
