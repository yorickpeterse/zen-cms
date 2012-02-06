module Sections
  #:nodoc:
  module Model
    ##
    # Model that represents a single section.
    #
    # @since 0.1
    # @event before_new_section
    # @event after_new_section
    # @event before_edit_section
    # @event after_edit_section
    # @event before_delete_section
    # @event after_delete_section
    #
    class Section < Sequel::Model
      include Zen::Model::Helper

      one_to_many :section_entries,
        :class => 'Sections::Model::SectionEntry',
        :eager => [:custom_field_values, :section_entry_status]

      many_to_many :custom_field_groups,
        :class => 'CustomFields::Model::CustomFieldGroup'

      many_to_many :category_groups,
        :class => 'Categories::Model::CategoryGroup'

      plugin :sluggable, :source => :name, :freeze => false

      plugin :events,
        :before_create  => :before_new_section,
        :after_create   => :after_new_section,
        :before_update  => :before_edit_section,
        :after_update   => :after_edit_section,
        :before_destroy => :before_delete_section,
        :after_destroy  => :after_delete_section

      ##
      # Searches for a number of sections of which the title or description
      # matches the search query.
      #
      # @example
      #  Sections::Model::Section.search('pages')
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(
          search_column(:name, query) | search_column(:description, query)
        )
      end

      ##
      # Specifies all validation rules for each section.
      #
      # @since  0.1
      #
      def validate
        validates_presence([
          :name,
          :comment_allow,
          :comment_require_account,
          :comment_moderate,
          :comment_format
        ])

        validates_max_length(255, [:name, :slug])

        validates_type(
          TrueClass,
          [:comment_allow, :comment_require_account, :comment_moderate]
        )

        validates_unique(:slug)
      end

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :slug, :description, :comment_format])

        super
      end
    end # Section
  end # Model
end # Sections
