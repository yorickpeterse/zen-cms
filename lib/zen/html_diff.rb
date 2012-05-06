module Zen
  ##
  # Module for generating HTML diffs using Diff::LCS and a custom callback
  # class. See {Zen::HTMLDiff.diff} and {Zen::HTMLDiff::Callback} for more
  # information on the usage and the returned HTML.
  #
  # @since 02-05-2012
  #
  module HTMLDiff
    ##
    # Gets the difference between the two given strings and returns a string
    # containing these differences formatted using HTML.
    #
    # @example
    #  old  = 'hello world'
    #  new  = 'Hello, world!'
    #  diff = Zen::HTMLDiff.diff(old, new)
    #
    #  puts diff # => "<div class=\"diff\">...</div>"
    #
    # @since  02-05-2012
    # @param  [String] old The old version of the string.
    # @param  [String] new The new version of the string.
    # @return [String]
    #
    def self.diff(old, new)
      callback = Callback.new

      old = old.join("\n") if old.is_a?(Array)
      new = new.join("\n") if new.is_a?(Array)

      Diff::LCS.traverse_sequences(
        old.to_s.split(/\r\n|\n/),
        new.to_s.split(/\r\n|\n/),
        callback
      )

      return callback.to_s
    end

    ##
    # Callback class for Diff::LCS that is used to format a diff using HTML. An
    # example of the resulting markup is the following:
    #
    #     <div class="diff">
    #         <table>
    #             <tbody>
    #                 <tr>
    #                     <td class="line">1</td>
    #                     <td class="line"></td>
    #                     <td class="line del">-Hello world</td>
    #                 </tr>
    #                 <tr>
    #                     <td class="line"></td>
    #                     <td class="line">1</td>
    #                     <td class="line ins">+Hello World</td>
    #                 </tr>
    #             </tbody>
    #         </table>
    #     </div>
    #
    # Example usage:
    #
    #     old      = '...'
    #     new      = '...'
    #     callback Zen::HTMLDiff::Callback.new
    #
    #     Diff::LCS.traverse_sequence(old, new, callback)
    #
    #     puts callback # => "<div class=...>"
    #
    # @since 02-05-2012
    #
    class Callback
      ##
      # Creates a new instance of the callback class.
      #
      # @since 02-05-2012
      #
      def initialize
        @output = ''
      end

      ##
      # Called when there's a line in A but not in B.
      #
      # @since 02-05-2012
      # @param [Diff::LCS::ContextChange] change
      #
      def discard_a(change)
        @output << %Q{
        <tr>
            <td class="line_number">#{change.old_position + 1}</td>
            <td class="line_number"></td>
            <td class="line del">-#{change.old_element}</td>
        </tr>
        }
      end

      ##
      # Called when there's a line in B but not in A.
      #
      # @since 02-05-2012
      # @param [Diff::LCS::ContextChange] change
      #
      def discard_b(change)
        @output << %Q{
        <tr>
            <td class="line_number"></td>
            <td class="line_number">#{change.new_position + 1}</td>
            <td class="line ins">+#{change.new_element}</td>
        </tr>
        }
      end

      ##
      # Called when both lines are identical.
      #
      # @since 02-05-2012
      # @param [Diff::LCS::ContextChange] change
      #
      def match(change)
        @output << %Q{
        <tr>
            <td class="line_number">#{change.old_position + 1}</td>
            <td class="line_number">#{change.new_position + 1}</td>
            <td class="line"> #{change.old_element}</td>
        </tr>
        }
      end

      ##
      # Returns the full HTML for the diff.
      #
      # @since  02-05-2012
      # @return [String]
      #
      def to_s
        return %Q{
        <div class="diff">
            <table class="no_sort">
                <tbody>
                    #{@output}
                </tbody>
            </table>
        </div>
        }
      end
    end # Callback
  end # HTMLDiff
end # Zen
