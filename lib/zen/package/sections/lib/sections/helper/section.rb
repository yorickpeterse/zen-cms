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
      # @since  0.2.8
      # @param  [Fixnum] section_entry_id The ID of the section entry to
      #  validate.
      # @param  [Fixnum] section_id The ID of the section to use when
      #  redirecting the user to the overview of all entries.
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

        entry.custom_field_values.each do |value|
          field_values[value.custom_field_id] = value
        end

        entry.custom_fields.each do |field|
          key = "custom_field_value_#{field.id}"

          if field.required \
          and (request.POST[key].nil? or request.POST[key].empty?)
            field_errors[:"custom_field_value_#{field.id}"] = \
              lang('zen_models.presence')

            next
          end

          next unless request.POST.key?(key)

          if field_values.key?(field.id)
            field_values[field.id].update(:value => request.POST[key])
          else
            entry.add_custom_field_value(
              :custom_field_id => field.id,
              :value           => request.POST[key]
            )
          end
        end

        return field_errors
      end
    end # Section
  end # Helper
end # Ramaze
