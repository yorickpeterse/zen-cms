#:nodoc:
module Sections
  #:nodoc:
  module Plugin
    ##
    #
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class SectionEntries
      include ::Zen::Plugin::Helper
      include ::Sections::Model

      ##
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a collection of custom configuration options that
      # determine how and what entries should be retrieved.
      # @option options [Fixnum/Integer] :limit
      # @option options [Fixnum/Integer] :offset
      # @option options [NilClass/String/Integer/Fixnum] :section
      # @option options [NilClass/String/Integer/Fixnum] :entry
      #
      def initialize(options = {})
        @options = {
          :limit          => 20,
          :offset         => 0,
          :section        => nil,
          :entry          => nil,
          :markup         => true,
          :comments       => true,
          :comment_markup => true
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
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Array/Sections::Model::SectionEntry]
      #
      def call
        # Create the list with models to load using eager()
        eager_models = [:custom_field_values, :categories, :section, :user]

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

          entries = SectionEntry.filter(:section_id => section_id)
            .eager(*eager_models)
            .limit(@options[:limit], @options[:offset])
            .all

        # Retrieve a single entry
        else
          # Retrieve it by it's slug
          if @options[:entry].class == String
            entries = SectionEntry.filter(:slug => @options[:entry])
              .eager(*eager_models)
              .all
          # Retrieve the entry by it's ID
          else
            entries = SectionEntry.filter(:id => @options[:entry])
              .eager(*eager_models)
              .all
          end
        end

        comment_format = nil

        # Loop through all entries so we can process our custom field values
        entries.each_with_index do |entry, index|
          if comment_format.nil?
            comment_format = entry.section.comment_format
          end

          field_values = {}
          user         = {}
          comments     = []

          # Store all the custom field values
          entry.custom_field_values.each do |v|
            name  = v.custom_field.slug.to_sym
            value = v.value

            # Convert the markup
            if @options[:markup] === true
              value = Zen::Plugin.call(
                'com.zen.plugin.markup', v.custom_field.format, value
              )
            end

            field_values[name] = value
          end

          # Get all the comments if the developer wants them
          if @options[:comments] === true
            entry.comments.each do |c|
              comment        = c.values
              comment[:user] = c.user.values

              # Convert the comment's markup
              if @options[:comment_markup]
                comment[:comment] = ::Zen::Plugin.call(
                  'com.zen.plugin.markup', comment_format, comment[:comment]
                )
              end

              comments.push(comment)
            end
          end

          # Get the user data
          if !entry.user.nil?
            user = entry.user.values
          end

          # Convert the entry to a hash and re-assign all data
          entry            = entry.values
          entry[:fields]   = field_values
          entry[:user]     = user
          entry[:comments] = comments
          entries[index]   = entry
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
