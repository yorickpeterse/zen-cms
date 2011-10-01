module Ramaze
  #:nodocL
  module Helper
    ##
    # Helper for the custom fields package.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    module CustomField
      ##
      # Validates a custom field group and returns the object if it's valid.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] custom_field_group_id An ID of a custom field group
      #  that has to be validated.
      # @return [CustomFields::Model::CustomFieldGroup]
      #
      def validate_custom_field_group(custom_field_group_id)
        group = ::CustomFields::Model::CustomFieldGroup[custom_field_group_id]

        if group.nil?
          message(:error, lang('custom_field_groups.errors.invalid_group'))
          redirect(::CustomFields::Controller::CustomFieldGroups.r(:index))
        else
          return group
        end
      end

      ##
      # Similar to validate_custom_field_group() this method validates a single
      # custom field and returns it if it's valid.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] custom_field_id The ID of the custom field to validate.
      # @param  [Fixnum] custom_field_group_id The ID of the field group the
      #  field is supposed to belong to.
      # @return [CustomFields::Model::CustomField]
      #
      def validate_custom_field(custom_field_id, custom_field_group_id)
        field = ::CustomFields::Model::CustomField[custom_field_id]

        if field.nil?
          message(:error, lang('custom_fields.errors.invalid_field'))
          redirect(
            ::CustomFields::Controller::CustomFields.r(
              :index, custom_field_group_id
            )
          )
        else
          return field
        end
      end

      ##
      # Validates a custom field type and returns it if it's valid.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] custom_field_type_id The ID of the field type to
      #  validate.
      # @return [CustomFields::Model::CustomFieldType]
      #
      def validate_custom_field_type(custom_field_type_id)
        type = ::CustomFields::Model::CustomFieldType[custom_field_type_id]

        if type.nil?
          message(:error, lang('custom_field_types.errors.invalid_type'))
          redirect(::CustomFields::Controller::CustomFieldTypes.r(:index))
        else
          return type
        end
      end
    end # CustomField
  end # Helper
end # Ramaze
