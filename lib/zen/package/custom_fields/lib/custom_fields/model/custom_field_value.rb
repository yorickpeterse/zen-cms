module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field value.
    #
    # @since  0.1
    #
    class CustomFieldValue < Sequel::Model
      many_to_one :custom_field , :class => 'CustomFields::Model::CustomField',
        :eager => [:custom_field_type]

      many_to_one :section_entry, :class => 'Sections::Model::SectionEntry'

      ##
      # Sets the value and serializes it based on the field type.
      #
      # @since  0.2.8
      # @param  [Mixed] value The value to store.
      #
      def value=(val)
        val  = Zen::Security.sanitize(val)
        type = custom_field.custom_field_type

        if !type.nil? and type.serialize == true
          val = [Marshal.dump(val)].pack('m')
        end

        super(val)
      end

      ##
      # Retrieves the value and optionally unserializes it.
      #
      # @since  0.2.8
      # @return [Mixed]
      #
      def value
        val  = super
        type = custom_field.custom_field_type

        if !type.nil? and type.serialize == true
          val = Marshal.load(val.unpack('m')[0]) rescue Marshal.load(val)
        end

        return val
      end

      ##
      # Retrieves the value of the custom field and converts it to the output
      # based on the markup engine specified in the custom field.
      #
      # @since  0.3
      # @return [String]
      #
      def html
        return ::Zen::Markup.convert(custom_field.format, value)
      end
    end # CustomFieldValue
  end # Model
end # CustomFields
