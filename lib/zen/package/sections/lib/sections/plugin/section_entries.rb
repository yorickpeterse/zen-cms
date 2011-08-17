#:nodoc:
module Sections
  #:nodoc:
  module Plugin
    ##
    # The SectionEntries plugin can be used to retrieve section entries as well
    # as the associated comments and user data. This allows you to relatively
    # easily build a list of entries (e.g. blog articles) without having to
    # retrieve and process the associated data manually.
    #
    # ## Usage
    #
    # Basic usage is as following:
    #
    #     entries = plugin(:section_entries, :limit => 10, :section => 'blog')
    #     entries.each do |e|
    #       puts e[:title]
    #     end
    #
    # The values of custom fields are stored under the key :fields. This key
    # contains a hash where the keys are the slugs of the custom fields and the
    # values the values for the current entry.
    #
    #     entries.each do |e|
    #       e[:fields][:thumbnail]
    #     end
    #
    # User data can be found in the key :user:
    #
    #     entries.each do |e|
    #       e[:user][:name]
    #     end
    #
    # Last but not least, comments can be found under the key :comments:
    #
    #     entries.each do |e|
    #       e[:comments].each do |c|
    #         c[:comment]
    #       end
    #     end
    #
    # For a full list of available options see
    # Sections::Plugin::SectionEntries.initialize.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class SectionEntries
      include ::Zen::Plugin::Helper

      ##
      # Creates a new instance of the plugin and validates/stores the given
      # configuration options. Please note that you always need to either
      # specify a section from which to retrieve all entries or a single entry
      # in order to use this plugin. You can retrieve a list of entries (or just
      # a single one) by specifying the ID or the slug:
      #
      #     plugin(:section_entries, :section => 'blog')
      #     plugin(:section_entries, :section => 10)
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a collection of custom configuration
      #  options that determine how and what entries should be retrieved.
      # @option options [Fixnum/Integer] :limit
      # @option options [Fixnum/Integer] :offset
      # @option options [NilClass/String/Integer/Fixnum] :section
      # @option options [NilClass/String/Integer/Fixnum] :entry
      # @option options [TrueClass] :markup When set to true the markup of all
      #  entries will be converted to the desired output (usually this is HTML).
      # @option options [TrueClass] :comments When set to true all comments for
      #  each entry will be retrieved. Set to false by default.
      # @option options [TrueClass] :comment_markup When set to true the markup
      #  of comments will be converted to the desired output.
      # @option options [TrueClass] :categories When set to true all categories
      #  for each entry will be retrieved as well. This is set to false by
      #  default.
      # @option options [Symbol] :order_by The name of the column to sort the
      #  entries on. This should be a column in the section_entries table.
      # @option options [Symbol] :order The sort order, can either be :asc or
      #  :desc.
      #
      def initialize(options = {})
        @options = {
          :limit          => 20,
          :offset         => 0,
          :section        => nil,
          :entry          => nil,
          :markup         => true,
          :comments       => false,
          :comment_markup => true,
          :categories     => false,
          :order_by       => :id,
          :order          => :desc
        }.merge(options)

        validate_type(@options[:limit] , :limit , [Fixnum, Integer])
        validate_type(@options[:offset], :offset, [Fixnum, Integer])

        validate_type(
          @options[:section],
          :section,
          [NilClass, String, Integer, Fixnum]
        )

        validate_type(
          @options[:entry],
          :entry,
          [NilClass, String, Integer, Fixnum]
        )

        validate_type(@options[:markup]  , :markup  , [TrueClass, FalseClass])
        validate_type(@options[:comments], :comments, [TrueClass, FalseClass])

        if ![:asc, :desc].include?(@options[:order])
          raise(
            Zen::ValidationError,
            "The sort order #{@options[:order]} is invalid"
          )
        end

        if @options[:section].nil? and @options[:entry].nil?
          raise(
            ArgumentError,
            "You need to specify either an entry or a section to retrieve."
          )
        end
      end

      ##
      # Fetches all the data and converts everything to a hash. Once this is
      # done either an array of entries or a single entry hash will be returned.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Array/Hash]
      #
      def call
        # Create the list with models to load using eager()
        eager_models = [:custom_field_values, :user]
        filter_hash  = {}

        [:comments, :categories].each do |key|
          eager_models.push(key) if @options[key] === true
        end

        # Get the section ID based on either the slug or ID.
        if !@options[:section].nil?
          # Retrieve the section by it's slug
          if @options[:section].class == String
            section_id = ::Sections::Model::Section[
              :slug => @options[:section]
            ].id
          else
            section_id = @options[:section]
          end

          filter_hash[:section_id] = section_id
        end

        # Retrieve a specific entry
        if !@options[:entry].nil?
          # Retrieve it by it's slug
          if @options[:entry].class == String
            filter_hash[:slug] = @options[:entry]
          # Retrieve the entry by it's ID
          else
            filter_hash[:id] = @options[:entry]
          end
        end

        # Get the correct status to retrieve
        filter_hash[:section_entry_status_id] = \
          ::Sections::Model::SectionEntryStatus[:name => 'published'].id

        # Get the entries
        entries = ::Sections::Model::SectionEntry.filter(filter_hash) \
          .eager(*eager_models) \
          .limit(@options[:limit], @options[:offset]) \
          .order(@options[:order_by].send(@options[:order])) \
          .all

        comment_format = nil

        # Loop through all entries so we can process our custom field values
        entries.each_with_index do |entry, index|
          field_values = {}
          user         = {}
          comments     = []
          categories   = []

          # Store all the custom field values
          entry.custom_field_values.each do |v|
            field = v.custom_field
            name  = field.slug.to_sym
            value = v.value

            # Convert the markup
            if @options[:markup] === true
              value = plugin(:markup, field.format, value)
            end

            field_values[name] = value
          end

          # Get all the comments if the developer wants them
          if @options[:comments] === true
            if comment_format.nil?
              comment_format = entry.section.comment_format
            end

            entry.comments.each do |c|
              comment        = c.values
              comment[:user] = c.user.values if c.user

              # Convert the comment's markup
              if @options[:comment_markup]
                comment[:comment] = plugin(
                  :markup,
                  comment_format,
                  comment[:comment]
                )
              end

              comments.push(comment)
            end
          end

          # Get the user data
          user = entry.user.values if !entry.user.nil?

          # Get all categories
          if @options[:categories] === true
            categories = entry.categories.map do |cat|
              cat.values
            end
          end

          # Convert the entry to a hash and re-assign all data
          entry              = entry.values
          entry[:fields]     = field_values
          entry[:user]       = user
          entry[:comments]   = comments
          entry[:categories] = categories
          entries[index]     = entry
        end

        entries = entries[0] if !@options[:entry].nil?

        return entries
      end
    end # SectionEntries
  end # Plugin
end # Sections
