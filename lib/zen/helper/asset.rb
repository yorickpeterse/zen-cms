require 'ramaze/gestalt'

module Ramaze
  module Helper
    ##
    # The Asset helper can be used to load Javascript and CSS files without
    # having to embedd them in your views. In order to tell the helper that
    # a CSS or Javascript file has to be loaded you'll have to call the
    # require_* method. For example, if we want to require a CSS file named
    # "reset" we'd do the following:
    #
    #     register_css('reset')
    #
    # Once you have your files required you can build the HTML by either calling
    # build_css or build_js.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @todo   Add support for compressing Javascript and CSS files.
    #
    module Asset
      @css = []
      @js  = []
      
      ##
      # Requires a new CSS file.
      #
      # @author Yorick Peterse
      # @param  [Symbol] files Paths to the CSS files to require.
      # @since  0.1
      #
      def require_css(*files)
        if @css.nil?
          @css = []
        end
        
        files.each do |file|
          file = file.to_sym
          
          if !@css.include?(file)
            @css.push(file)
          end
        end
      end
      
      ##
      # Requires a new Javascript file.
      #
      # @author Yorick Peterse
      # @param  [Symbol] files Paths to the Javascript files to require.
      # @since  0.1
      #
      def require_js(*files)
        if @js.nil?
          @js = []
        end
        
        files.each do |file|
          file = file.to_sym
          
          if !@js.include?(file)
            @js.push(file)
          end
        end
      end
      
      ##
      # Builds the HTML for all CSS tags using Gestalt.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [String]
      #
      def build_css
        g = Ramaze::Gestalt.new
        
        @css.each do |css|
          css = "/admin/css/#{css}.css"
          g.link :rel => "stylesheet", :href => css, :media => "all", :type => "text/css"
        end
        
        return g.to_s
      end
      
      ##
      # Builds the HTML for all Javascript tags using Gestalt.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [String]
      #
      def build_js
        g = Ramaze::Gestalt.new
        
        @js.each do |js|
          js = "/admin/js/#{js}.js"
          g.script(:src => js) {}
        end
        
        return g.to_s
      end
    end
  end
end
