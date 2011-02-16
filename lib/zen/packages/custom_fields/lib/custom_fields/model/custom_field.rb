module CustomFields
  module Models
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
      one_to_many :custom_field_values, :class => "CustomFields::Models::CustomFieldValue"
      
      plugin :sluggable, :source => :name, :freeze => false
      
      ##
      # Validates rules used whenever the model is created or saved.
      #
      # @author Yorick Peterse
      # @since  0.1
      # 
      def validate
        validates_presence              [:name, :type, :format, :required, :visual_editor]
        validates_max_length 255      , [:name]
        validates_type       TrueClass, [:required, :visual_editor]
        validates_integer               [:sort_order, :textarea_rows, :text_limit]
        
        validates_presence :slug unless new?
        validates_unique   :slug
      end
    end
  end
end
