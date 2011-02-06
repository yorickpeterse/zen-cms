require 'enumerator'

module Zen
  module Liquid
    ##
    # Module that provides several methods that can be used to ease the process of
    # creating Liquid tags.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    module General
      include ::Ramaze::Helper::CGI
      
      ##
      # Parses all additional data specified in the tag open block
      # and turns it into a key/value hash. This makes it easier to
      # use tags with key/value variables such as the following:
      #
      # bc. {% my_tag name="yorick" %}
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] string the raw string specified after the tag name.
      # @return [Hash]
      #
      def parse_key_values string
        key_values = {}
        
        # Thanks to Michael Trommer (https://github.com/entropie) for coming up with
        # this way of parsing the key/value string.
        string.split(/["']([^"]*)["']|\s/).reject{ |s| s.empty? }.each_slice(2) do |key, val|
          key_values[ key[0..-2].to_s ] = val
        end
        
        # Returns the data in the format of {'key' => 'value'}
        return key_values
      end
      
      ##
      # Converts the given input data to HTML using the specified markup engine.
      #
      # @example
      #
      #  markup_to_html("h2. Hello world!", :textile)
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] markup The raw markup that has to be converted to HTML.
      # @param  [Symbol] engine The markup engine to use such as Textile.
      # @return [String] 
      #
      def markup_to_html markup, engine
        engine = engine.to_sym
        
        case engine
          when :textile
            markup = RedCloth.new(markup).to_html
          when :markdown
            markup = RDiscount.new(markup).to_html
          when :plain
            markup = h(markup)  
        end
        
        return markup
      end
    end
  end
end
