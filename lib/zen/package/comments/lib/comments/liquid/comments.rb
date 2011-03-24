#:nodoc:
module Comments
  #:nodoc:
  module Liquid
    ##
    # Tag that can be used to display a number of comments based on the section entry ID
    # or the slug of a section entry.
    #
    # @example
    #  {% comments section_entry="hello-world" limit="10" %}
    #    {{comment}}
    #  {% endcomments %}
    #
    # The following arguments can be used for this tag:
    #
    # * section_entry: the slug of the section entry for which to retrieve all comments
    # * limit: the amount of comments to retriee
    # * offset: the offset from which to start retrieving comments
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Comments < ::Liquid::Block
      include ::Ramaze::Helper::CGI
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
      def initialize(tag_name = 'comments', arguments = '', html = '')
        super
        
        @arguments = {
          'limit'  => nil,
          'offset' => nil
        }.merge(parse_key_values(arguments))
        
        @args_parsed = false
        
        if !@arguments.key?('section_entry') or @arguments['section_entry'].empty?
          raise(
            ArgumentError, 
            "You need to specify a section entry's slug in order to retrieve a set of comments"
          )
        end
      end
      
      ##
      # Retrieves all comments and renders the tag block.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def render context
        if @args_parsed == false
          @arguments = merge_context(@arguments, context)
        end
        
        @args_parsed = true
        result       = []
        filter_hash  = {:status => 'open'}
        comments     = []
        format       = nil
        
        if @arguments.key?('section_entry')
          entry = ::Sections::Models::SectionEntry[:slug => @arguments['section_entry']]
          
          return if entry.nil?
          filter_hash[:section_entry_id] = entry.id
        end
    
        comments = ::Comments::Models::Comment
          .eager(:user, :section_entry)
          .filter(filter_hash)
          .limit(@arguments['limit'], @arguments['offset'])
          
        context['total_rows'] = comments.count
        
        comments.each_with_index do |comment, index|
          context['index'] = index
          
          if format.nil?
            section = comment.section_entry.section
            format  = section.comment_format
          end
          
          comment.values.each { |k, v| context[k.to_s] = v }
          
          # Convert the comment body into HTML
          context['comment'] = Zen::Plugin.call(
            'com.zen.plugin.markup', format.to_sym, context['comment']
          )
          
          ['email', 'name', 'website'].each do |c|
            if context[c].nil? or context[c].empty?
              context[c] = comment.user.send(c)
            end
          end
          
          result.push(render_all(@nodelist, context))
        end
        
        result.push(render_all(@nodelist, context)) if result.empty?
        return result
      end
    end
  end
end
