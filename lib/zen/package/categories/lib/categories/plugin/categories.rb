#:nodoc
module Categories
  #:nodoc
  class Plugin
    ##
    # The Categories plugin is a plugin that makes it easy to retrieve a list of
    # categories (or a single category) for a given group or category. This
    # plugin can be called as following:
    #
    #     plugin(:categories)
    #
    # Retrieving categories can be done by either specifying a slug of a
    # group/category or an ID:
    #
    #     # Retrieves all categories for the group with an ID of 5.
    #     plugin(:categories, :group => 5)
    #
    #     # Retrieves all categories for the group with a slug of "example"
    #     plugin(:categories, :group => 'example')
    #
    # Simply said, if the value passed to ``:group`` is a number it's assumed to
    # be an ID, otherwise the categories will be retrieved using a
    # group/category slug.
    #
    # A full list of all the available options can be found in the {#initialize}
    # method's documentation.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Categories
      include ::Zen::Plugin::Helper

      ##
      # Creates a new instance of the plugin and stores the configuration
      # options.
      #
      # @example Retrieving by group
      #  plugin(:categories, :limit => 10, :group => 5)
      #
      # @example Retrieving a category
      #  plugin(:category, :category => 'my-category')
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash containing a set of options used to
      #  determine how the categories should be retrieved and which one should
      #  be retrieved.
      # @option options [Fixnum] :limit The maximum amount of categories to
      #  retrieve.
      # @option options [Fixnum] :offset The row offset, useful for pagination
      #  systems.
      # @option options [String|Fixnum] :group The name or ID of the category
      #  group for which to retrieve all categories.
      # @option options [String/Fixnum] :category The slug or ID of the
      #  category to retrieve. Setting this option will cause the plugin to
      #  ignore the offset and limit options.
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
          raise(
            ArgumentError,
            "You need to specify either a category or category group."
          )
        end

        if !@options[:group].nil? and !@options[:category].nil?
          raise(
            ArgumentError,
            "You can't specify both a category and a category group."
          )
        end

        group_class = @options[:group].class
        cat_class   = @options[:category].class
        allowed     = [Integer, String, Fixnum]

        # Validate the types
        unless @options[:group].nil?
          validate_type(@options[:group], :group, allowed)
        end

        unless @options[:category].nil?
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
          if @options[:group].class == Integer \
          or @options[:group].class == Fixnum
            category_group = ::Categories::Model::CategoryGroup[
              @options[:group]
            ]
          else
            category_group = ::Categories::Model::CategoryGroup[
              :name => @options[:group]
            ]
          end

          # Since we require a group in this case we'll raise an error if the
          # group doesn't exist. If we were to return an empty value this may
          # confuse the developer.
          if category_group.nil?
            raise(
              ArgumentError,
              "No category group could be found for \"#{@options[:group]}\""
            )
          end

          # Get all the categories according to our specified configuration
          # options and the category group that was retrieved earlier on.
          categories = ::Categories::Model::Category \
            .filter(:category_group_id => category_group.id) \
            .limit(@options[:limit], @options[:offset]) \
            .all

        # Retrieve the category for the specified ID or slug
        else
          if @options[:category].class == Integer \
          or @options[:category].class == Fixnum
            categories = ::Categories::Model::Category[@options[:category]]
          else
            categories = ::Categories::Model::Category[
              :slug => @options[:category]
            ]
          end
        end

        # Convert all categories to a hash
        if categories.is_a?(Array)
          categories.each_with_index do |cat, index|
            categories[index] = cat.values
          end
        elsif categories.respond_to?(:values)
          categories = categories.values
        end

        return categories
      end
    end # Categories
  end # Plugin
end # Categories
