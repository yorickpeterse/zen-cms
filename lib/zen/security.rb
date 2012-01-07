module Zen
  ##
  # Module for dealing with various security related actions such as sanitizing
  # user input/output.
  #
  # @since 07-01-2012
  #
  module Security
    class << self
      ##
      # Sanitizes the string by escaping all Etanni template tags in it so that
      # they aren't executed. Optionally this method can also remove all
      # dangerous HTML using Loofah.
      #
      # @example
      #  input = 'Hello #{puts 10}'
      #
      #  Zen::Input.sanitize(input) # => "Hello \#\{puts 10\}"
      #
      # @since  03-01-2012
      # @param  [String] input The input string to sanitize.
      # @param  [TrueClass|FalseClass] clean_html When set to true certain HTML
      #  elements will be removed using Loofah.
      # @return [String] The sanitized string.
      #
      def sanitize(input, clean_html = false)
        return input unless input.is_a?(String)

        # Cheap way of escaping the template tags.
        input = input.gsub('<?r', '\<\?r') \
          .gsub('?>', '\?\>') \
          .gsub('#{', '\#\{') \
          .gsub('}', '\}')

        if clean_html == true
          input = Loofah.fragment(input) \
            .scrub!(:whitewash) \
            .scrub!(:nofollow) \
            .to_s
        end

        return input
      end
    end # class << self
  end # Input
end # Zen
