module Sections
  module Liquid
    ##
    # Tag that can be used to retrieve a number of sections. By default
    # all sections will be retrieved but you can specify a specific section
    # by setting the "section" key.
    #
    # @example Basic usage
    #  {% sections section="pages" %}
    #    {{description}}
    #  {% endsections %}
    #
    # The following arguments can be specified:
    #
    # * section
    # * limit
    # * offset
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Sections < ::Liquid::Block
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
      def initialize tag_name, arguments, html
        super
        
        @arguments = {
          'limit'   => nil,
          'offset'  => nil
        }
        
        @arguments = @arguments.merge(parse_key_values(arguments))
      end
      
      ##
      # Renders the tag
      #
      # @author Yorick Peterse
      # @param  [Object] context The Liquid context for the current tag.
      # @return [Array]
      #
      def render context
        result = []
        
        if !@arguments.key?('section')
          sections = ::Sections::Models::Section.limit(@arguments['limit'], @arguments['offset'])
        else
          sections = ::Sections::Models::Section.filter(:slug => @arguments['section'])
            .limit(@arguments['limit'], @arguments['offset'])
        end
        
        sections.each do |s|
          s.values.each do |k, v|
            context[k.to_s] =v
          end
          
          result << render_all(@nodelist, context)
        end
        
        return result
      end
    end
  end
end
