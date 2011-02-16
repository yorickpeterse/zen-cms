require 'ramaze/gestalt'

module Comments
  module Liquid
    ##
    # Liquid tag that can be used to generate the required form elements for submitting
    # comments. It's important to remember that you still need to define your own
    # form fields such as those for the name and Email, this tag merely generates
    # the form open/closing tags and a few hidden fields. The following field (names)
    # are required when creating a comment form:
    #
    # * name
    # * website
    # * email
    # * comment
    #
    # Basic usage of this tag is as following:
    #
    # bc. {% comment_form section_entry="hello-world" %}
    #   <p>
    #     <label for="name">Name</label>
    #     <input type="text" name="name" id="name" />
    #   </p>
    #   <input type="submit" value="Submit comment" />
    # {% endcomment_form %}
    #
    # The following arguments can be used:
    #
    # * section_entry: the slug of the entry
    # * section_entry_id: the ID of the entry
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CommentForm < ::Liquid::Block
      include ::Zen::Liquid::General
      include ::Zen::Liquid::ControllerBehavior
      include ::Ramaze::Helper::CSRF
      include ::Ramaze::Helper::BlueForm
      
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
      def initialize(tag_name = 'comments_form', arguments = '', html = '')
        super
        
        @arguments   = parse_key_values(arguments)
        @args_parsed = false
      end
      
      ##
      # Renders the tag block.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def render(context)
        if @args_parsed == false
          @arguments.each do |k, v|
            v = v.to_s
            
            if context.has_key?(v)
              @arguments[k] = h(context[v])
            end
          end
        end
        
        @args_parsed = true
        g            = Ramaze::Gestalt.new
        user_html    = ''
        
        super(context).each { |h| user_html += h }
        
        # Get our section to which this form belongs
        if @arguments.key?('section_entry')
          section_entry = ::Sections::Models::SectionEntry[:slug => @arguments['section_entry']]
        else
          section_entry = ::Sections::Models::SectionEntry[@arguments['section_entry_id'].to_i]
        end
        
        # Get the section entry's ID
        if !section_entry.nil?
          section_entry_id = section_entry.id
        else
          section_entry_id = nil
        end
        
        # Get the user's ID if he/she is logged in
        if !session[:user].nil?
          user_id = session[:user].id
        else
          user_id = nil
        end
        
        g_html = form_for(nil, :method => :post, :action => Comments::Controllers::CommentsForm.r(:save)) do |f|
          f.input_hidden(:csrf_token   , get_csrf_token)
          f.input_hidden(:section_entry, section_entry_id)
          f.input_hidden(:user_id      , user_id)
          
          user_html
        end
        
        return g_html
      end
    end
  end
end
