module Zen
  module Liquid
    ##
    # The Redirect tag can be used to redirect a user from one URL to another. 
    #
    # @example
    #  {% redirect "blog/index" %}
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Redirect < ::Liquid::Tag
      include ::Ramaze::Helper::Redirect
      include ::Zen::Liquid::ControllerBehavior
     
      ##
      # Creates a new instance of this tag by passing the tag name, arguments and HTML
      # tokens to the construct.
      # 
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] tokens All tokens (HTML mostly) inside the tag block.
      #
      def initialize tag_name, arguments, tokens
        @url = arguments.gsub('"', '').gsub("'", '')
      end
      
      ##
      # Redirects the user to a certain page based on the arguments specified in the
      # constructor method.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Object] context The current Liquid context
      # 
      def render context
        if @url.nil? or @url.empty?
          raise ArgumentError, "You need to specify a URL in order to redirect a user"
        end
        
        redirect(@url)
      end
    end
  end
end
