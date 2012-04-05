module Ramaze
  #:nodocL
  module Helper
    ##
    # Helper for the custom fields package.
    #
    # @since  0.2.8
    #
    module CustomField
      ##
      # Validates a custom field group and returns the object if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] custom_field_group_id An ID of a custom field group
      #  that has to be validated.
      # @return [CustomFields::Model::CustomFieldGroup]
      #
      def validate_custom_field_group(custom_field_group_id)
        redirect_invalid_field_group unless custom_field_group_id =~ /\d+/

        group = ::CustomFields::Model::CustomFieldGroup[custom_field_group_id]

        if group.nil?
          redirect_invalid_field_group
        else
          return group
        end
      end

      ##
      # Similar to validate_custom_field_group() this method validates a single
      # custom field and returns it if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] custom_field_id The ID of the custom field to validate.
      # @param  [Fixnum] custom_field_group_id The ID of the field group the
      #  field is supposed to belong to.
      # @return [CustomFields::Model::CustomField]
      #
      def validate_custom_field(custom_field_id, custom_field_group_id)
        unless custom_field_id =~ /\d+/
          redirect_invalid_field(custom_field_group_id)
        end

        field = ::CustomFields::Model::CustomField[custom_field_id]

        if field.nil?
          redirect_invalid_field(custom_field_group_id)
        else
          return field
        end
      end

      ##
      # Validates a custom field type and returns it if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] custom_field_type_id The ID of the field type to
      #  validate.
      # @return [CustomFields::Model::CustomFieldType]
      #
      def validate_custom_field_type(custom_field_type_id)
        redirect_invalid_field_type unless custom_field_type_id =~ /\d+/

        type = ::CustomFields::Model::CustomFieldType[custom_field_type_id]

        if type.nil?
          redirect_invalid_field_type
        else
          return type
        end
      end

      ##
      # Redirects the user back to the field groups overview and shows a message
      # informing the user that the group he/she tried to access was invalid.
      #
      # @since 05-04-2012
      #
      def redirect_invalid_field_group
        message(:error, lang('custom_field_groups.errors.invalid_group'))
        redirect(::CustomFields::Controller::CustomFieldGroups.r(:index))
      end

      ##
      # Redirects the user to the custom field types overview and informs
      # him/her that the type he/she tried to access was invalid.
      #
      # @since 05-04-2012
      #
      def redirect_invalid_field_type
        message(:error, lang('custom_field_types.errors.invalid_type'))
        redirect(::CustomFields::Controller::CustomFieldTypes.r(:index))
      end

      ##
      # Redirects the user to the overview of all custom fields of a given group
      # and informs the user that the field he/she tried to access is invalid.
      #
      # @since 05-04-2012
      # @param [Fixnum] custom_field_group_id The ID of the group to use for
      #  redirecting the user.
      #
      def redirect_invalid_field(custom_field_group_id)
        message(:error, lang('custom_fields.errors.invalid_field'))
        redirect(
          ::CustomFields::Controller::CustomFields.r(
            :index, custom_field_group_id
          )
        )
      end
    end # CustomField
  end # Helper
end # Ramaze
