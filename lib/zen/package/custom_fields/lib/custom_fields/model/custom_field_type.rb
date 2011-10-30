module CustomFields
  #:nodoc:
  module Model
    ##
    # Model for managing custom field types.
    #
    # @since  0.2.8
    #
    class CustomFieldType < Sequel::Model
      include Zen::Model::Helper

      many_to_one :custom_field_method,
        :class => 'CustomFields::Model::CustomFieldMethod'

      ##
      # Searches for a set of custom field types.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:custom_field_types__name, query)) \
          .eager(:custom_field_method)
      end

      ##
      # Returns a hash where the keys are the IDs of all custom field types and
      # the values the full language strings based on the value of the column
      # "language_string".
      #
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
      # @since  0.2.8
      #
      def validate
        validates_presence([:name, :language_string, :custom_field_method_id])
        validates_integer(:custom_field_method_id)
        validates_type(TrueClass, [:serialize, :allow_markup])
        validates_format(/^[a-zA-Z\-_0-9\s]*$/, [:html_class])

        validates_max_length(255, [:name, :language_string, :html_class])
      end
    end # CustomFieldType
  end # Model
end # CustomFields
