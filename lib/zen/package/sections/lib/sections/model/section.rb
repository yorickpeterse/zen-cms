#:nodoc:
module Sections
  #:nodoc:
  module Model
    ##
    # Model that represents a single section.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Section < Sequel::Model
      one_to_many(
        :section_entries,
        :class => "Sections::Model::SectionEntry",
        :eager => [:custom_field_values, :section_entry_status]
      )

      many_to_many(
        :custom_field_groups,
        :class => "CustomFields::Model::CustomFieldGroup"
      )

      many_to_many(
        :category_groups,
        :class => "Categories::Model::CategoryGroup"
      )

      plugin(:sluggable, :source => :name, :freeze => false)

      ##
      # Specifies all validation rules for each section.
      #
      # @author Yorick Peterse
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

        validates_presence(:slug) unless new?
        validates_max_length(255, [:name, :slug])

        validates_type(
          TrueClass,
          [:comment_allow, :comment_require_account, :comment_moderate]
        )

        validates_unique(:slug)
      end
    end # Section
  end # Model
end # Sections
