#:nodoc:
module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field value.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFieldValue < Sequel::Model
      many_to_one(:custom_field , :class => "CustomFields::Model::CustomField")
      many_to_one(:section_entry, :class => "Sections::Model::SectionEntry")

      ##
      # Sets the value and serializes it based on the field type.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Mixed] value The value to store.
      #
      def value=(val)
        type = custom_field.custom_field_type

        if !type.nil? and type.serialize === true
          val = [Marshal.dump(val)].pack('m')
        end

        super(val)
      end

      ##
      # Retrieves the value and optionally unserializes it.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @return [Mixed]
      #
      def value
        val  = super
        type = custom_field.custom_field_type

        if !type.nil? and type.serialize === true
          val = Marshal.load(val.unpack('m')[0]) rescue Marshal.load(val)
        end

        return val
      end
    end # CustomFieldValue
  end # Model
end # CustomFields
