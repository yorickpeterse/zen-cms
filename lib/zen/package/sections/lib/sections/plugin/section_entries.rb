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
          :limit    => 20,
          :offset   => 0,
          :section  => nil,
          :entry    => nil,
          :markup   => true,
          :comments => false
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
        # Retrieve multiple entries
        if !@options[:section].nil?
          # Retrieve the section by it's slug
          if @options[:section].class == String
            section_id = Section[:slug => @options[:section]].id
          else
            section_id = @options[:section]
          end

          entries = SectionEntry.filter(:section_id => section_id)
            .limit(@options[:limit], @options[:offset])
            .all

        # Retrieve a single entry
        else
          # Retrieve it by it's slug
          if @options[:entry].class == String
            entries = SectionEntry.filter(:slug => @options[:entry]).all
          # Retrieve the entry by it's ID
          else
            entries = SectionEntry.filter(@options[:entry]).all
          end
        end

        # Loop through all entries so we can process our custom fields
        

        return entries
      end

    end
  end
end
