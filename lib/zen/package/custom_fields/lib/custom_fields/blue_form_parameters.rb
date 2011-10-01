module CustomFields
  ##
  # The BlueFormParameters module is used to build an array of parameters for
  # various BlueForm methods based on the type and method of a custom field. Out
  # of the box this module provides a set of methods that can be used to
  # generate the parameters for most methods in the BlueForm helper that ships
  # with Ramaze. However, there may be a time when you want to add your own
  # method. Don't worry, this is quite easy.
  #
  # Each method (they should be class methods) in this module takes two
  # parameters, the first one is an instance of
  # {CustomFields::Model::CustomField} and the second one an instance of
  # {CustomFields::Model::CustomFieldValue}. The return value should be an
  # array containing all the parameters that will be passed to BlueForm.
  #
  # Let's start with the basic skeleton of such a method:
  #
  #     module CustomFields
  #       module BlueFormParameters
  #         def self.my_method(field, field_value)
  #           params = [:input_text]
  #
  #           return params
  #         end
  #       end
  #     end
  #
  # So far the only thing this method does is telling BlueForm that we want to
  # invoke the ``input_text()`` method. Let's add some extra parameters to it
  # such as the label and name:
  #
  #     module CustomFields
  #       module BlueFormParameters
  #         def self.my_method(field, field_value)
  #           params = [
  #             :input_text,
  #             field.label,
  #             "custom_field_value_#{field.id}"
  #           ]
  #
  #           return params
  #         end
  #       end
  #     end
  #
  # The second parameter in this array is the label of the field, the third the
  # name. The names of these fields should be specified in the format of
  # ``custom_field_value_N`` where ``N`` is the ID of the custom field.
  #
  # Let's add our value to the list. BlueForm allows you to specify a hash
  # containing additional parameters (including the value). Adding this hash to
  # the array is as easy as, well, just adding it:
  #
  #     module CustomFields
  #       module BlueFormParameters
  #         def self.my_method(field, field_value)
  #           params = [
  #             :input_text,
  #             field.label,
  #             "custom_field_value_#{field.id}",
  #             {:value => field_value.value}
  #           ]
  #
  #           return params
  #         end
  #       end
  #     end
  #
  # And there you have it, a very basic example of how to add custom parameters
  # allowing you to build your own HTML markup for your fields.
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
      #  for filling in classes, values, etc.
      # @param  [CustomFields::Model::CustomFieldValue] field_value The
      #  value of the custom field for a given entry.
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

        if !type.html_class.nil? and !type.html_class.empty?
          params.last[:class] = type.html_class
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
        params.last[:values]   = params.last[:values].invert

        params.last.delete(:size)

        return params
      end
    end # class << self
  end # BlueFormParameters
end # CustomFields
