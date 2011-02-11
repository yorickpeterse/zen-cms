module Users
  module Liquid
    ##
    # Tag that can be used to retrieve details about a single user. When using this
    # tag you can use the database table's column names as the keys, multiple keys
    # will result in multiple WHERE/AND clauses. In order to retrieve a user with
    # the Email address "me@awesome.com" you'd do the following:
    #
    # bc. {% user email="me@awesome.com" %}
    #   {{name}}
    # {% enduser %}
    #
    # If you want to add an extra condition simply do the following:
    #
    # bc. {% user email="me@awesome.com" status="open" %}
    #   {{name}}
    # {% enduser %}
    #
    # Note that this class is a Liquid block, not a tag. This means that you'll have to
    # specify the closing tag. The reason for this is that there are multiple columns
    # for the user table and using a tag in combination of a variable would result in
    # more code.
    # 
    # @author Yorick Peterse
    # @since  0.1
    #
    class User < ::Liquid::Block
      include ::Zen::Liquid::General
      
      ##
      # Initializes the class, parses the tag and retrieves the user for the specified tag.
      #
      # @author Yorick Peterse
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] html The HTML inside the block.
      # @since  0.1
      # 
      def initialize tag_name, arguments, markup
        super
        
        @arguments = {}
        arguments  = parse_key_values(arguments)
        
        arguments.each do |k, v|
          @arguments[k.to_sym] = v
        end
        
        @user = {}
        user  = ::Users::Models::User[@arguments]
        
        if !user.nil?
          user.values.each do |k, v|
            @user[k.to_s] = v
          end
        end
      end
      
      ##
      # Renders the tag
      #
      # @author Yorick Peterse
      # @param  [Object] context The Liquid context for the current tag.
      # @return [Array]
      #
      def render context
        @user.each do |k, v|
          context[k] = v
        end
        
        render_all(@nodelist, context)
      end
    end
  end
end
