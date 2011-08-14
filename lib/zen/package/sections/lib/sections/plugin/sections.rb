#:nodoc:
module Sections
  #:nodoc:
  module Plugin
    ##
    # Plugin that can be used to display sections and their details. If you want
    # to display section entries instead you should use the plugin
    # Sections::Plugin::SectionEntries.
    #
    # ## Usage
    #
    #     section = plugin(:sections, :section => 10)
    #     section.name # => "My Section"
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Sections
      include ::Zen::Plugin::Helper

      ##
      # Creates a new instance of the plugin and saves/validates the given
      # configuration options.
      #
      # @example
      #  plugin = Sections::Plugin::Sections.new(:section => 10)
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] options Hash with a set of configuration files to use.
      #
      def initialize(options = {})
        @options = {
          :limit   => 20,
          :offset  => 0,
          :section => nil
        }.merge(options)

        validate_type(@options[:limit]  , :limit  , [Fixnum, Integer])
        validate_type(@options[:offset] , :offset , [Fixnum, Integer])

        validate_type(
          @options[:section],
          :section,
          [NilClass, Integer, Fixnum, String]
        )
      end

      ##
      # Retrieves the section(s) based on the given configuration options. When
      # multiple sections are retrieved they're returned as an array, otherwise
      # a single instance of Sections::Model::Sections will be returned.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Array/Sections::Model::Section] List of all sections that were
      #  retrieved or an instance of Sections::Model::Section in case a specific
      #  section was retrieved from the database.
      #
      def call
        # Retrieve a single section
        if !@options[:section].nil?
          # Retrieve a section by it's slug
          if @options[:section].class == String
            sections = ::Sections::Model::Section[:slug => @options[:section]]
          # Retrieve a section by it's ID
          else
            sections = ::Sections::Model::Section[@options[:section]]
          end
        # Retrieve mutliple sections
        else
          sections = ::Sections::Model::Section \
            .limit(@options[:limit], @options[:offset]) \
            .all
        end

        # Convert every section to a hash
        if sections.class == Array
          sections.each_with_index do |section, index|
            sections[index] = section.values
          end
        else
          sections = sections.values
        end

        return sections
      end
    end # Sections
  end # Plugin
end # Sections
