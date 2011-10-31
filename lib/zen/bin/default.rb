module Zen
  #:nodoc:
  module Bin
    ##
    # The default command that is executed.
    #
    # @since 0.3
    #
    class Default < Shebang::Command
      command :default
      banner  'Zen is a modular CMS written using Ramaze.'
      usage   'zen [COMMAND] [OPTIONS]'

      o :h, :help   , 'Shows this help message'  , :method => :help
      o :v, :version, 'Shows the current version', :method => :version

      ##
      # Creates a new instance of the command and creates a list of all the
      # installed commands.
      #
      # @since 0.3
      #
      def initialize
        list_commands

        super
      end

      ##
      # Method that is invoked when this command is called.
      #
      # @since 0.3
      #
      def index
        help
      end

      protected

      ##
      # Shows the current version of Zen.
      #
      # @since 0.3
      #
      def version
        puts Zen::VERSION
        exit
      end

      ##
      # Generates an array of "rows" where each row contains the name and
      # description of a command. The descriptions of all commands are aligned
      # based on the length of the longest command name.
      #
      # This method has been ported from Ramaze.
      #
      # @since  0.3
      # @return [Array]
      #
      def list_commands
        cmds = Shebang::Commands.dup
        cmds.delete(:default)

        return if cmds.empty?

        cmd_string = ''
        longest    = cmds.map { |name, klass| name.to_s }.sort[0].size

        cmds.each do |name, klass|
          name = name.to_s
          desc = klass.instance_variable_get(:@__banner).to_s

          while name.length <= longest
            name += ' '
          end

          cmd_string += "  #{name}    #{desc}\n"
        end

        self.class.help('Commands', cmd_string)
      end
    end # Default
  end # Bin
end # Zen
