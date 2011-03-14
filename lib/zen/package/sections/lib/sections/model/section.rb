module Sections
  module Models
    ##
    # Model that represents a single section. This model has the following
    # relations:
    #
    # * section entries (one to many), eager loads the custom field values
    # * custom field group (many to many)
    # * category groups (many to many)
    #
    # The following plugins are loaded by this model:
    #
    # * sluggable (source: "name")
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Section < Sequel::Model
      one_to_many(
        :section_entries, 
        :class => "Sections::Models::SectionEntry", 
        :eager => [:custom_field_values]
      )
      
      many_to_many(
        :custom_field_groups, 
        :class => "CustomFields::Models::CustomFieldGroup"
      )

      many_to_many(
        :category_groups,
        :class => "Categories::Models::CategoryGroup"
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
          :name, :comment_allow, :comment_require_account, :comment_moderate, :comment_format
        ])

        validates_presence(:slug) unless new?
        validates_max_length(255, [:name, :slug])
        
        validates_type(
          TrueClass, 
          [:comment_allow, :comment_require_account, :comment_moderate]
        )
        
        validates_unique(:slug)
      end
    end
  end
end
