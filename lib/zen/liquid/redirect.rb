module Zen
  module Liquid
    ##
    # The Redirect tag can be used to redirect a user from one URL to another. 
    #
    # @example
    #  {% redirect "blog/index" %}
    #
    # Optionally you can redirect a user to a 404 page by doing the following:
    #
    #     {% redirect "404" %}
    #
    # This will render the 404 template but without changing the current URL.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Redirect < ::Liquid::Tag
      include ::Ramaze::Helper::Redirect
      include ::Zen::Liquid::ControllerBehavior
      include ::Ramaze::Helper::Render
      
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
      def initialize(tag_name = 'redirect', arguments = '', tokens = '')
        super

        @url = arguments.gsub('"', '').gsub("'", '').strip
      end
      
      ##
      # Redirects the user to a certain page based on the arguments specified in the
      # constructor method.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Object] context The current Liquid context
      # 
      def render(context)
        if @url.nil? or @url.empty?
          raise(ArgumentError, "You need to specify a URL in order to redirect a user")
        end
        
        # 404 URLs are treated differently than other URLs
        if @url == '404'
          theme      = ::Zen::Package[session[:settings][:theme]]
          not_found  = theme.directory + "/templates/404.liquid"

          if File.exist?(not_found)
            respond(action.instance.render_file(not_found), 404)
          else
            respond("The requested page could not be found", 404)
          end
        else
          redirect(@url)
        end
      end
    end
  end
end
