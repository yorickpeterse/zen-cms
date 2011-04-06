#:nodoc
module Comments
  module Plugin
    ##
    # The Comments plugin can be used to display a list of comments for a given section
    # entry.
    #
    # ## Usage
    #
    # If we want to retrieve all comments for the entry "hello-world":
    #
    #     Zen::Plugin.call('com.zen.plugin.comments', :entry => 'hello-world').each do |comment|
    #       comment.website
    #     end
    #
    # For more information about all available options see 
    # Comments::Plugin::Comments#initialize
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Comments
      include ::Zen::Plugin
      include ::Sections::Model
      include ::Comments::Model
      
      ##
      # Creates a new instance of the plugin and saves the specified configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a set of options that determine how the comments
      # should be retrieved.
      # @option options [String/Integer] :entry The slug or ID of the entry for which to
      # retrieve all comments.
      # @option options [Integer] :limit The maximum amount of comments to retrieve.
      # @option options [Integer] :offset The row offset, useful for pagination systems.
      # @option options [Boolean] :markup When set to true (default) the markup used in
      # each comment will be converted to the appropriate format.
      #
      def initialize(options = {})
        @options = {
          :limit  => 20,
          :offset => 0,
          :markup => true,
          :entry  => nil
        }.merge(options)

        # Validate the :entry option
        validate_type(@options[:limit] , :limit , [Integer, Fixnum])
        validate_type(@options[:offset], :offset, [Integer, Fixnum])
        validate_type(@options[:entry] , :entry , [Integer, String, Fixnum])
        validate_type(@options[:markup], :markup, [FalseClass, TrueClass])
      end

      ##
      # Retrieves all comments based on the options set in the construct. The comments are
      # returned as an array.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def call
        # Get the section entry
        if @options[:entry].class == String
          entry = SectionEntry[:slug => @options[:entry]]
        else
          entry = SectionEntry[@options[:entry]]
        end 

        # Now that we have the entry and the section we can start retrieving all the 
        # comments.
        comments = Comment.filter(:section_entry_id => entry.id)
                          .limit(@options[:limit], @options[:offset])
                          .all

        # Don't bother with all code below this if/end if we don't want to convert the
        # markup of each comment.
        if @options[:markup] === false
          return comments
        end

        # Get the section for the comments. This is required to determine what markup is 
        # used for the comments.
        section = entry.section

        # Convert the markup of each comment
        comments.each_with_index do |comment, index|
          comment.comment = ::Zen::Plugin.call(
            'com.zen.plugin.markup', section.comment_format, comment.comment
          )

          comments[index] = comment
        end

        return comments
      end

    end
  end
end
