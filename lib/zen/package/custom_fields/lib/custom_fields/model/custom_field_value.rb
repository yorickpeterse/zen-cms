#:nodoc:
module CustomFields
  #:nodoc:
  module Model
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
      many_to_one(:custom_field , :class => "CustomFields::Model::CustomField")
      many_to_one(:section_entry, :class => "Sections::Model::SectionEntry")

      ##
      # Hook that is executed before saving a field's value. This hook is used to clean
      # up all values making it easier to process them at a later stage.
      #
      # @author Yorick Peterse
      # @since  0.2.4
      #
      def before_save
        # T-t-t-t-that's all folks!
        if !self.value.nil?
          self.value.gsub!(/\r\n/, "\n")
        end
      end
    end
  end
end
