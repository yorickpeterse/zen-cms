module CustomFields
  #:nodoc:
  module Model
    ##
    # Model for managing retrieving custom fields.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomField < Sequel::Model
      include Zen::Model::Helper

      one_to_many :custom_field_values,
        :class => "CustomFields::Model::CustomFieldValue"

      many_to_one :custom_field_type,
        :class => 'CustomFields::Model::CustomFieldType',
        :eager => :custom_field_method

      plugin :sluggable, :source => :name, :freeze => false

      ##
      # Searches for a set of custom fields.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:name, query))
      end

      ##
      # Validates rules used whenever the model is created or saved.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence([
          :name,
          :format,
          :custom_field_group_id,
          :custom_field_type_id
        ])

        validates_max_length(255, [:name, :slug])
        validates_type(TrueClass, [:required, :text_editor])

        validates_integer([
          :sort_order,
          :textarea_rows,
          :text_limit,
          :custom_field_group_id,
          :custom_field_type_id
        ])

        validates_presence(:slug) unless new?
        validates_unique(:slug)
      end
    end # CustomField
  end # Model
end # CustomFields
