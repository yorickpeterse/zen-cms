#:nodoc:
module Sections
  #:nodoc:
  module Plugin
    ##
    # The SectionEntries plugin can be used to retrieve section entries as well as the
    # associated comments and user data. This allows you to relatively easily build a list
    # of entries (e.g. blog articles) without having to retrieve and process the 
    # associated data manually.
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
    # The values of custom fields are stored under the key :fields. This key contains a
    # hash where the keys are the slugs of the custom fields and the values the values for
    # the current entry.
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
    # For a full list of available options see Sections::Plugin::SectionEntries.initialize.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class SectionEntries
      include ::Zen::Plugin::Helper
      include ::Sections::Model

      ##
      # Creates a new instance of the plugin and validates/stores the given configuration
      # options. Please note that you always need to either specify a section from which
      # to retrieve all entries or a single entry in order to use this plugin. You can
      # retrieve a list of entries (or just a single one) by specifying the ID or the 
      # slug:
      #
      #     plugin(:section_entries, :section => 'blog')
      #     plugin(:section_entries, :section => 10)
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a collection of custom configuration options that
      # determine how and what entries should be retrieved.
      # @option options [Fixnum/Integer] :limit
      # @option options [Fixnum/Integer] :offset
      # @option options [NilClass/String/Integer/Fixnum] :section
      # @option options [NilClass/String/Integer/Fixnum] :entry
      # @option options [TrueClass] :markup When set to true the markup of all entries will
      # be converted to the desired output (usually this is HTML).
      # @option options [TrueClass] :comments When set to true all comments for each entry
      # will be retrieved.
      # @option options [TrueClass] :comment_markup When set to true the markup of comments
      # will be converted to the desired output.
      # @option options [TrueClass] :categories When set to true all categories for each
      # entry will be retrieved as well.
      #
      def initialize(options = {})
        @options = {
          :limit          => 20,
          :offset         => 0,
          :section        => nil,
          :entry          => nil,
          :markup         => true,
          :comments       => true,
          :comment_markup => true,
          :categories     => true
        }.merge(options)

        validate_type(@options[:limit]   , :limit   , [Fixnum, Integer])
        validate_type(@options[:offset]  , :limit   , [Fixnum, Integer])
        validate_type(@options[:section] , :section , [NilClass, String, Integer, Fixnum])
        validate_type(@options[:entry]   , :entry   , [NilClass, String, Integer, Fixnum])
        validate_type(@options[:markup]  , :markup  , [TrueClass, FalseClass])
        validate_type(@options[:comments], :comments, [TrueClass, FalseClass])

        if @options[:section].nil? and @options[:entry].nil?
          raise(
            ArgumentError, 
            "You need to specify either an entry or a section to retrieve."
          )
        end
      end

      ##
      # Fetches all the data and converts everything to a hash. Once this is done either
      # an array of entries or a single entry hash will be returned.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Array/Hash]
      #
      def call
        # Create the list with models to load using eager()
        eager_models = [:custom_field_values, :categories, :section, :user]
        filter_hash  = {}

        if @options[:comments] === true
          eager_models.push(:comments)
        end

        # Retrieve multiple entries
        if !@options[:section].nil?
          # Retrieve the section by it's slug
          if @options[:section].class == String
            section_id = Section[:slug => @options[:section]].id
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

        # Get the entries
        entries = SectionEntry.filter(filter_hash)
          .eager(*eager_models)
          .limit(@options[:limit], @options[:offset])
          .all

        comment_format = nil

        # Loop through all entries so we can process our custom field values
        entries.each_with_index do |entry, index|
          if comment_format.nil?
            comment_format = entry.section.comment_format
          end

          field_values = {}
          user         = {}
          comments     = []
          categories   = []

          # Store all the custom field values
          entry.custom_field_values.each do |v|
            name  = v.custom_field.slug.to_sym
            value = v.value

            # Convert the markup
            if @options[:markup] === true
              value = plugin(:markup, v.custom_field.format, value)
            end

            field_values[name] = value
          end

          # Get all the comments if the developer wants them
          if @options[:comments] === true
            entry.comments.each do |c|
              comment        = c.values

              if c.user
                comment[:user] = c.user.values
              end

              # Convert the comment's markup
              if @options[:comment_markup]
                comment[:comment] = plugin(:markup, comment_format, comment[:comment])
              end

              comments.push(comment)
            end
          end

          # Get the user data
          if !entry.user.nil?
            user = entry.user.values
          end

          # Get all categories
          categories = entry.categories.map do |cat|
            cat.values
          end

          # Convert the entry to a hash and re-assign all data
          entry              = entry.values
          entry[:fields]     = field_values
          entry[:user]       = user
          entry[:comments]   = comments
          entry[:categories] = categories
          entries[index]     = entry
        end

        # Do we only want a single entry?
        if !@options[:entry].nil?
          entries = entries[0]
        end

        return entries
      end

    end
  end
end
