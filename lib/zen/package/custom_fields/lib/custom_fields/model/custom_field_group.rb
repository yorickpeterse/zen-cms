module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field group.
    #
    # @since  0.1
    #
    class CustomFieldGroup < Sequel::Model
      include Zen::Model::Helper

      one_to_many :custom_fields,
        :class => 'CustomFields::Model::CustomField',
        :order => :sort_order

      many_to_many :sections, :class => 'Sections::Model::Section'

      ##
      # Searches for a set of custom field groups.
      #
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
      # @since  0.1
      #
      def validate
        validates_presence(:name)
        validates_max_length(255, :name)
      end
    end # CustomFieldGroup
  end # Model
end # CustomFields
