#:nodoc:
module Zen
  #:nodoc:
  module Liquid
    ##
    # Tag block that can be used to strip leading and trailing characters from
    # the text inside of the block. This tag can be extremely useful when you're
    # displaying elements seperated by a comma and want to remove the last comma.
    #
    # @example
    #  {% strip end=", " %}
    #    Hello, world, 
    #  {% endstrip %}
    #
    # This tag has the following options:
    #
    # * start
    # * end
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Strip < ::Liquid::Block
      include ::Zen::Liquid::General
      
      ##
      # Creates a new instance of the block and passes the tag name,
      # all additional arguments and the HTML to the constructor method.
      #
      # @author Yorick Peterse
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] html The HTML inside the block.
      # @since  0.1
      #
      def initialize(tag_name = 'strip', arguments = '', html = '')
        super
        
        @arguments = {'start' => '', 'end' => ''}
        @arguments = @arguments.merge(parse_key_values(arguments))
      end
      
      ##
      # Renders the tag block. We'll retrieve the content inside the block,
      # trim it and return it.
      # 
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Object] context The Liquid context for the current tag
      #
      def render context
        html = super
        html = html.join
        html = html.gsub(/^#{@arguments['start']}/, '').gsub(/#{@arguments['end']}$/, '')
        
        return html
      end
    end
  end
end
