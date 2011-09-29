#:nodoc:
module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field group.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFieldGroup < Sequel::Model
      one_to_many :custom_fields,
        :class => 'CustomFields::Model::CustomField',
        :order => :sort_order

      many_to_many :sections, :class => 'Sections::Model::Section'

      ##
      # Validates rules used whenever the model is created or saved.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence(:name)
        validates_max_length(255, :name)
      end
    end # CustomFieldGroup
  end # Model
end # CustomFields
