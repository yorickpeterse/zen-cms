#:nodoc:
module CustomFields
  ##
  # The BlueFormParameters module is used to build an array of parameters for
  # various BlueForm methods based on the type and method of a custom field.
  #
  # @author Yorick Peterse
  # @since  0.2.8
  #
  module BlueFormParameters
    class << self
      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#input_text.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [CustomFields::Model::CustomField] field The custom field to use
      # for filling in classes, values, etc.
      # @param  [CustomFields::Model::CustomFieldValue] field_value The
      # value of the custom field for a given entry.
      # @return [Array]
      #
      def input_text(field, field_value)
        type   = field.custom_field_type
        value  = field_value.value rescue nil
        params = [
          :input_text,
          field.name,
          "custom_field_value_#{field.id}",
          {:value => value}
        ]

        if !field.text_limit.nil?
          params.last[:maxlength] = field.text_limit
        end

        if !field.description.nil?
          params.last[:placeholder] = field.description
        end

        if !field.format.nil? and !field.format.empty? \
        and type.allow_markup === true
          params.last[:'data-format'] = field.format
        end

        if !type.css_class.nil? and !type.css_class.empty?
          params.last[:class] = type.css_class
        end

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#input_password.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.input_text
      #
      def input_password(field, field_value)
        params    = input_text(field, field_value)
        params[0] = :input_password

        params.last.delete(:'data-format')

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#textarea.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.input_text
      #
      def textarea(field, field_value)
        params    = input_text(field, field_value)
        params[0] = :textarea

        if !field.textarea_rows.nil?
          params.last[:rows] = field.textarea_rows
        end

        # Remove the class "text]editor" if the field does not allow the text
        # editor to be used.
        if field.text_editor === false
          params.last[:class].gsub!('text_editor', '')
        end

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#input_radio.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.input_text
      #
      def input_radio(field, field_value)
        type   = field.custom_field_type
        value  = field_value.value rescue nil
        params = [
          :input_radio,
          field.name,
          "custom_field_value_#{field.id}",
          value,
          {}
        ]

        # Convert the string containing the possible values to a hash.
        if !field.possible_values.nil? and !field.possible_values.empty?
          params.last[:values] = {}

          field.possible_values.split(/\n|\r\n/).each do |row|
            if row.include?('|')
              row        = row.split('|', 2)
              key, value = row[0], row[1]
            else
              key = value = row
            end

            params.last[:values][key] = value
          end
        end

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#input_checkbox.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.input_radio
      #
      def input_checkbox(field, field_value)
        params    = input_radio(field, field_value)
        params[0] = :input_checkbox

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#select.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.input_text
      #
      def select(field, field_value)
        type   = field.custom_field_type
        value  = field_value.value rescue nil
        params = [
          :select,
          field.name,
          "custom_field_value_#{field.id}",
          {:selected => value, :size => 1}
        ]

        # Convert the string containing the possible values to a hash.
        if !field.possible_values.nil? and !field.possible_values.empty?
          params.last[:values] = {}

          field.possible_values.split(/\n|\r\n/).each do |row|
            if row.include?('|')
              row        = row.split('|', 2)
              key, value = row[0], row[1]
            else
              key = value = row
            end

            params.last[:values][key] = value
          end
        end

        return params
      end

      ##
      # Generates the required parameters for
      # Ramaze::Helper::BlueForm::Form#select but allows multiple values to be
      # selected.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @see    CustomFields::BlueFormParameters.select
      #
      def select_multiple(field, field_value)
        params = select(field, field_value)

        params.last[:multiple] = :multiple
        params.last.delete(:size)

        return params
      end

      private
    end # class << self
  end # BlueFormParameters
end # CustomFields
