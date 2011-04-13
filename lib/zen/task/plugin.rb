#:nodoc:
module Zen
  #:nodoc:
  module Task
    ##
    # Task used for lising plugins and such.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Plugin < Thor
      namespace :plugin

      desc('list', 'Lists all installed plugins')

      ##
      # Lists all installed plugins.
      #
      # @author Yorick Peterse
      # @since  0.2
      #
      def list
        table = []
        table.push(['Name', 'Author', 'Identifier', 'Class'])
        table.push(['------', '------', '------', '------'])

        Zen::Plugin.plugins.each do |ident, ext|
          table.push([ext.name, ext.author, ext.identifier, ext.plugin.to_s])
        end

        print_table(table)
      end

    end
  end
end
