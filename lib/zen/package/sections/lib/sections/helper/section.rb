module Ramaze
  module Helper
    ##
    # Helper for the sections package.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    module Section
      ##
      # Validates the section ID and returns the section if it's valid.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] section_id The ID of the section to validate.
      # @return [Sections::Model::Section]
      #
      def validate_section(section_id)
        section = Sections::Model::Section[section_id]

        if section.nil?
          message(:error, lang('sections.errors.invalid_section'))
          redirect(Sections::Controller::Sections.r(:index))
        else
          return section
        end
      end

      ##
      # Validates a section entry and returns it if it's valid.
      #
      # 
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] section_entry_id The ID of the section entry to
      # validate.
      # @param  [Fixnum] section_id The ID of the section to use when
      # redirecting the user to the overview of all entries.
      # @return [Sections::Model::SectionEntry]
      #
      def validate_section_entry(section_entry_id, section_id)
        entry = Sections::Model::SectionEntry[section_entry_id]

        if entry.nil?
          message(:error, lang('section_entries.errors.invalid_entry'))
          redirect(Sections::Controller::SectionEntries.r(:index, section_id))
        else
          return entry
        end
      end
    end # Section
  end # Helper
end # Ramaze
