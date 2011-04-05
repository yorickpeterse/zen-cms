#:nodoc:
module Users
  #:nodoc:
  module Liquid
    ##
    # Block that can be used to retrieve a number of users and show their details.
    # Basic usage of this tag is as following:
    #
    #     {% users limit="10" offset="5" %}
    #         {{email}}
    #     {% endusers %}
    #
    # Note that this tag will retrieve a list of users, if you want to only retrieve
    # a single user it's best to use the tag "zen_user" defined under Users::Liquid::User.
    #
    # The following keys can be set:
    #
    # * limit
    # * offset
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Users < ::Liquid::Block
      include ::Zen::Liquid::General
      
      ##
      # Initializes the class, parses the tag and retrieves the users for the specified tag.
      #
      # @author Yorick Peterse
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] html The HTML inside the block.
      # @since  0.1
      # 
      def initialize tag_name, arguments, markup
        super
        
        @arguments = {
          'limit'  => nil,
          'offset' => nil
        }
        
        @arguments = @arguments.merge(parse_key_values(arguments))
        @users     = []
        users      = ::Users::Model::User.limit(@arguments['limit'], @arguments['offset'])
        
        users.each do |u|
          hash = {}
          
          u.values.each do |k, v|
            hash[k.to_s] = v
          end
          
          @users.push(hash)
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
        result = []
        
        @users.each do |user|
          user.each do |k, v|
            context[k] = v
          end
          
          result << render_all(@nodelist, context)
        end
        
        result << render_all(@nodelist, context) if result.empty?
        return result
      end
    end
  end
end
