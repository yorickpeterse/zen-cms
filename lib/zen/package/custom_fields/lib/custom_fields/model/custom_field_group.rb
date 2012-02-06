module CustomFields
  #:nodoc:
  module Model
    ##
    # Model that represents a single custom field group.
    #
    # @since 0.1
    # @event before_new_custom_field_group
    # @event after_new_custom_field_group
    # @event before_edit_custom_field_group
    # @event after_edit_custom_field_group
    # @event before_delete_custom_field_group
    # @event after_delete_custom_field_group
    #
    class CustomFieldGroup < Sequel::Model
      include Zen::Model::Helper

      one_to_many :custom_fields,
        :class => 'CustomFields::Model::CustomField',
        :order => :sort_order

      many_to_many :sections, :class => 'Sections::Model::Section'

      plugin :events,
        :before_create  => :before_new_custom_field_group,
        :after_create   => :after_new_custom_field_group,
        :before_update  => :before_edit_custom_field_group,
        :after_update   => :after_edit_custom_field_group,
        :before_destroy => :before_delete_custom_field_group,
        :after_destroy  => :after_delete_custom_field_group

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

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :description])

        super
      end
    end # CustomFieldGroup
  end # Model
end # CustomFields
