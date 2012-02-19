module CustomFields
  #:nodoc:
  module Model
    ##
    # Model for managing custom field methods.
    #
    # @since  0.2.8
    #
    class CustomFieldMethod < Sequel::Model
      one_to_many :custom_field_types,
        :class => 'CustomFields::Model::CustomFieldType'

      plugin :association_dependencies, :custom_field_types => :delete
    end # CustomFieldType
  end # Model
end # CustomFields
