#:nodoc:
module Zen
  #:nodoc:
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
      #     {% my_tag name="yorick" %}
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] string the raw string specified after the tag name.
      # @return [Hash] A key/value hash of all specified arguments.
      #
      def parse_key_values(string)
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
      # Merges the values in the given context with the hash. This means that if the
      # Liquid context has a key that matches a value in the hash that key's value
      # will become the value of the key in the hash. Confused? Assume our context has
      # a key of "username" which is set to "YorickPeterse". If our hash had a key
      # who's value is "username" that value would be replaced with "YorickPeterse".
      #
      # If context was a hash (it's an object) this would result in something like the
      # following:
      #
      #     context = {'username' => 'YorickPeterse'}
      #     hash    = {'selected_user' => 'username'}
      # 
      #     merge_context(hash, context) # => {'selected_user' => 'YorickPeterse'}
      #
      # This method will also automatically escape all variables using the h() method
      # so you don't have to worry about nasty input.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Hash] hash The input hash that may contain Liquid variables
      # @param  [Liquid::Context] context The Liquid context from which to extract any
      # variables set in the hash.
      # @return [Hash] The merged hash.
      #
      def merge_context(hash, context)
        if hash.class != Hash
          raise(
            TypeError, 
            "The first argument of this method should be a hash instead of \"#{hash.class}\""
          )
        end

        hash.each do |k, v|
          v = v.to_s

          # Check if the Liquid context has a matching key and extract the value of that key
          # if this is the case.
          if context.respond_to?('key?')
            if context.key?(v)
              hash[k] = h(context[v])
            end
          else
            if context.has_key?(v)
              hash[k] = h(context[v])
            end
          end
        end

        return hash
      end
       
    end
  end
end
