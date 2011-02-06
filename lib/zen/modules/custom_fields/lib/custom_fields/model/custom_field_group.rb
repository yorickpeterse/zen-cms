module CustomFields
  module Models
    ##
    # Model that represents a single custom field group. This model has
    # the following relations:
    #
    # * custom fields (one to many, ordered by "sort_order")
    # * sections (many to many)
    #
    # When creating or saving a group you are required to specify a "name" field.
    # This field may also be no longer than 255 characters.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFieldGroup < Sequel::Model
      one_to_many  :custom_fields, :class => "CustomFields::Models::CustomField", :order => :sort_order
      many_to_many :sections     , :class => "Sections::Models::Section"
      
      ##
      # Validates rules used whenever the model is created or saved.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence        [:name]
        validates_max_length 255, [:name]
      end
    end
  end
end
