#:nodoc
module Categories
  #:nodoc
  module Plugin
    ##
    # The Categories plugin can be used to display a list of categories
    #
    # ## Usage
    #
    # A basic example of how to use this plugin looks like the following:
    #
    #     Zen::Plugin.call('com.zen.plugin.categories', :group => 'blog').each do |category|
    #       puts category.name
    #     end
    #
    # For more information about the available options see 
    # Zen::Plugin::Categories#initialize().
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Categories
      include ::Categories::Model
      include ::Zen::Plugin::Helper

      ##
      # Creates a new instance of the plugin and stores the configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash containing a set of options used to determine how the
      # categories should be retrieved and which one should be retrieved.
      # @option options [Integer] :limit The maximum amount of categories to retrieve.
      # @option options [Integer] :offset The row offset, useful for pagination systems.
      # @option options [String/Integer] :group The name or ID of the category group for 
      # which to retrieve all categories.
      # @option options [String/Integer] :category The slug or ID of the category to 
      # retrieve. Setting this option will cause the plugin to ignore the offset and 
      # limit options.
      #
      def initialize(options = {})
        @options = {
          :limit    => 20,
          :offset   => 0,
          :group    => nil,
          :category => nil
        }.merge(options)

        # Validate the specified options
        if @options[:group].nil? and @options[:category].nil?
          raise(ArgumentError, "You need to specify either a category or category group.")
        end

        if !@options[:group].nil? and !@options[:category].nil?
          raise(ArgumentError, "You can't specify both a category and a category group.")
        end

        group_class = @options[:group].class
        cat_class   = @options[:category].class
        allowed     = [Integer, String, Fixnum]

        # Validate the types
        if !@options[:group].nil?
          validate_type(@options[:group], :group, allowed)
        end

        if !@options[:category].nil?
          validate_type(@options[:category], :category, allowed)
        end

        validate_type(@options[:limit] , :limit , [Fixnum, Integer])
        validate_type(@options[:offset], :offset, [Fixnum, Integer])
      end

      ##
      # Retrieves all categories based on the given configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Array] A list of all categories.
      #
      def call
        categories = []

        # Retrieve the categories for a given group]]
        if !@options[:group].nil?
          # Get the group for an ID or a name
          if @options[:group].class == Integer or @options[:group].class == Fixnum
            category_group = CategoryGroup[@options[:group]]
          else
            category_group = CategoryGroup[:name => @options[:group]]
          end

          # Since we require a group in this case we'll raise an error if the group 
          # doesn't exist. If we were to return an empty value this may confuse the 
          # developer.
          if category_group.nil?
            raise("No category group could be found for \"#{@options[:group]}\"")
          end

          # Get all the categories according to our specified configuration options
          # and the category group that was retrieved earlier on.
          categories = Category.filter(:category_group_id => category_group.id)
            .limit(@options[:limit], @options[:offset])
            .all
          
        # Retrieve the category for the specified ID or slug
        else
          if @options[:category].class == Integer or @options[:category].class == Fixnum
            categories = Category[@options[:category]]
          else
            categories = Category[:slug => @options[:category]]
          end
        end

        return categories
      end

    end
  end
end
