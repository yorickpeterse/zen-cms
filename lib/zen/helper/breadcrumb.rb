#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper that can be used to quickly generate breadcrumbs without having
    # to manually write the HTML separators and formatting the output correctly.
    # In order to create a set of breadcrumbs we first need to call the 
    # set_breadcrumbs method:
    #
    #     set_breadcrumbs(segment1, segment2, segment3, etc)
    #
    # Each argument will be a segment of the breadcrumbs, separated by a custom 
    # character. Retrieving the breadcrumbs is super easy:
    #
    #     get_breadcrumbs
    #
    # This will generate the correct HTML and return it, all you have to do is 
    # output it.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    module Breadcrumb
      @breadcrumbs = []
      
      ##
      # Appends each element to the list of breadcrumb segments.
      #
      # @example
      #  set_breadcrumbs "Articles", "Edit"
      #
      # Note that you'll have to manually specify anchor tags, this method won't 
      # automatically generate URLs.
      # 
      # @author Yorick Peterse
      # @param  [Array] args Array of segments for the breadcrumbs.
      # @since  0.1
      #
      def set_breadcrumbs(*args)
        @breadcrumbs = args
      end
      
      ##
      # Retrieves all breacrumbs and separates them either by "&raquo;" or a 
      # custom element set as the first argument of this method.
      #
      # @example
      #  get_breadcrumbs # => "Articles &raquo; Edit"
      #
      # @example
      #  get_breadcrumbs ">" # => "Articles > Edit"
      #
      # @author Yorick Peterse
      # @param  [String] separator The HTML character to use for separating each 
      # segment.
      # @return [String]
      # 
      def get_breadcrumbs(separator = "&raquo;")
        if !@breadcrumbs or @breadcrumbs.empty?
          return
        end
        
        html      = ''
        separator = " #{separator} "
        
        @breadcrumbs.each do |segment|
          html += segment + separator
        end
        
        return html.chomp(separator)
      end
    end # Breadcrumb
  end # Helper
end # Ramaze
