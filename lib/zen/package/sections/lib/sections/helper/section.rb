module Ramaze
  module Helper
    ##
    # Helper for the sections package.
    #
    # @since  0.2.8
    #
    module Section
      ##
      # Validates the section ID and returns the section if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] section_id The ID of the section to validate.
      # @return [Sections::Model::Section]
      #
      def validate_section(section_id)
        redirect_invalid_section unless section_id =~ /\d+/

        section = Sections::Model::Section[section_id]

        if section.nil?
          redirect_invalid_section
        else
          return section
        end
      end

      ##
      # Validates a section entry and returns it if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] section_entry_id The ID of the section entry to
      #  validate.
      # @param  [Fixnum] section_id The ID of the section to use when
      #  redirecting the user to the overview of all entries.
      # @return [Sections::Model::SectionEntry]
      #
      def validate_section_entry(section_entry_id, section_id)
        unless section_entry_id =~ /\d+/
          redirect_invalid_section_entry(section_id)
        end

        entry = Sections::Model::SectionEntry[section_entry_id]

        if entry.nil?
          redirect_invalid_section_entry(section_id)
        else
          return entry
        end
      end

      ##
      # Creates or updates a set of custom fields for a given section entry.
      #
      # @since 17-02-2012
      # @param [Sections::Model::SectionEntry] entry The entry for which to
      #  create or update the fields.
      # @return [Hash] Hash containing any errors for the custom fields.
      #
      def process_custom_fields(entry)
        request.params.delete('id')

        field_values = {}
        field_errors = {}
        revision     = entry.add_revision(
          :user_id => (user.id rescue entry.user_id)
        )

        entry.custom_fields.each do |field|
          key = "custom_field_value_#{field.id}"

          if field.required \
          and (request.POST[key].nil? or request.POST[key].empty?)
            field_errors[:"custom_field_value_#{field.id}"] = \
              lang('zen_models.presence')

            next
          end

          next unless request.POST.key?(key)

          entry.add_custom_field_value(
            :custom_field_id => field.id,
            :value           => request.POST[key],
            :revision_id     => revision.id
          )
        end

        if field_errors.empty?
          entry.update(:revision_id => revision.id)
        else
          revision.destroy
        end

        return field_errors
      end

      ##
      # Redirects the user to the sections overview and shows a message
      # informing the user that the section he/she tried to access is invalid.
      #
      # @since 09-04-2012
      #
      def redirect_invalid_section
        message(:error, lang('sections.errors.invalid_section'))
        redirect(Sections::Controller::Sections.r(:index))
      end

      ##
      # Redirects the user to the overview of section entries for a given
      # section and shows a message informing the user that the section entry
      # he/she tried to access is invalid.
      #
      # @since 09-04-2012
      # @param [Fixnum] section_id The ID of the section.
      #
      def redirect_invalid_section_entry(section_id)
        message(:error, lang('section_entries.errors.invalid_entry'))
        redirect(Sections::Controller::SectionEntries.r(:index, section_id))
      end
    end # Section
  end # Helper
end # Ramaze
