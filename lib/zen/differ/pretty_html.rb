module Zen
  ##
  # Namespace for Differ related code.
  #
  # @since 30-04-2012
  #
  module Differ
    ##
    # HTML formatter for Differ. This formatter wraps the diff in an unordered
    # list opposed to only spitting out `<ins>` and `<del>` tags.
    #
    # @since 30-04-2012
    #
    module PrettyHTML
      class << self
        ##
        # Formats a diff.
        #
        # @since  30-04-2012
        # @param  [Differ::Change] change
        # @return [String]
        #
        def format(change)
          output = '<div class="diff"><ul>'

          if change.change?
            output += as_change(change)
          elsif change.insert?
            output += as_insert(change)
          elsif change.delete?
            output += as_delete(change)
          end

          output += '</ul></div>'

          return output
        end

        private

        ##
        # Formats a newly inserted line.
        #
        # @since  30-04-2012
        # @param  [Differ::Change] change
        # @return [String]
        #
        def as_insert(change)
          output = ''

          change.insert.split("\n").each do |line|
            output += %Q{<li><ins>+ #{line}</ins></li>}
          end

          return output
        end

        ##
        # Formats a deleted line.
        #
        # @since  30-04-2012
        # @param  [Differ::Change] change
        # @return [String]
        #
        def as_delete(change)
          output = ''

          change.delete.split("\n").each do |line|
            output += %Q{<li><del>- #{line}</del></li>}
          end

          return output
        end

        ##
        # Formats a changed block. A block is changed if it has both added and
        # deleted content.
        #
        # @since  30-04-2012
        # @param  [Differ::Change] change
        # @return [String]
        #
        def as_change(change)
          as_delete(change) << as_insert(change)
        end
      end # class << self
    end # PrettyHTML
  end # Differ
end # Zen
