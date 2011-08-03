#:nodoc:
module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field. This model has the following
    # relations:
    #
    # * custom field values (one to many)
    #
    # The following plugins are loaded:
    #
    # * sluggable (source: "name")
    #
    # When creating or saving a new custom field several validation rules are used.
    # For more information on these rules see the validate() method of this model.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomField < Sequel::Model
      one_to_many(
        :custom_field_values,
        :class => "CustomFields::Model::CustomFieldValue"
      )

      many_to_one(
        :custom_field_type,
        :class => 'CustomFields::Model::CustomFieldType',
        :eager => :custom_field_method
      )

      plugin :sluggable, :source => :name, :freeze => false

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

        validates_max_length(255, [:name])

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
