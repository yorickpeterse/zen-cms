#:nodoc:
module CustomFields
  #:nodoc:
  module Model
    ##
    # Model for managing custom field types.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class CustomFieldType < Sequel::Model
      many_to_one(
        :custom_field_method, 
        :class => 'CustomFields::Model::CustomFieldMethod'
      )

      ##
      # Returns a hash where the keys are the IDs of all custom field types and
      # the values the full language strings based on the value of the column
      # "language_string".
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @return [Hash]
      #
      def self.type_hash
        rows = {}
        
        CustomFieldType.select(:id, :language_string).each do |row|
          rows[row.id] = lang(row.language_string)
        end

        return rows
      end

      ##
      # Validates the model before inserting/updating the database record.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def validate
        validates_presence([:name, :language_string, :custom_field_method_id])
        
        validates_integer(:custom_field_method_id)

        validates_type(TrueClass, [:serialize, :allow_markup])
      end
    end # CustomFieldType
  end # Model
end # CustomFields
