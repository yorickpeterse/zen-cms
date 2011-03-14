#:nodoc:
module CustomFields
  #:nodoc:
  module Models
    ##
    # Model that represents a single custom field value. This model
    # has the following relations:
    #
    # * custom field (many to one)
    # * section entry (many to one)
    #
    # This model is basically just a join table with some extra columns.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFieldValue < Sequel::Model
      many_to_one(:custom_field , :class => "CustomFields::Models::CustomField")
      many_to_one(:section_entry, :class => "Sections::Models::SectionEntry")
    end
  end
end
