module CustomFields
  #:nodoc:
  module Model
    ##
    # Model for managing retrieving custom fields.
    #
    # @since 0.1
    # @event before\_new\_custom\_field
    # @event after\_new\_custom\_field
    # @event before\_edit\_custom\_field
    # @event after\_edit\_custom\_field
    # @event before\_delete\_custom\_field
    # @event after\_delete\_custom\_field
    #
    class CustomField < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing all the columns the user can set.
      #
      # @since 17-02-2012
      #
      COLUMNS = [
        :name,
        :slug,
        :description,
        :sort_order,
        :format,
        :possible_values,
        :required,
        :text_editor,
        :textarea_rows,
        :text_limit,
        :custom_field_group_id,
        :custom_field_type_id
      ]

      one_to_many :custom_field_values,
        :class => "CustomFields::Model::CustomFieldValue"

      many_to_one :custom_field_type,
        :class => 'CustomFields::Model::CustomFieldType',
        :eager => [:custom_field_method]

      plugin :association_dependencies, :custom_field_values => :delete

      plugin :sluggable, :source => :name, :freeze => false

      plugin :events,
        :before_create  => :before_new_custom_field,
        :after_create   => :after_new_custom_field,
        :before_update  => :before_edit_custom_field,
        :after_update   => :after_edit_custom_field,
        :before_destroy => :before_delete_custom_field,
        :after_destroy  => :after_delete_custom_field

      ##
      # Searches for a set of custom fields.
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

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :slug, :description, :format])

        super
      end
    end # CustomField
  end # Model
end # CustomFields
