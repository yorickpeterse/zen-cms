#:nodoc:
module Sections
  #:nodoc:
  module Model
    ##
    # Model that represents a singe section entry. This model has the following
    # relations:
    #
    # * comments (one to many)
    # * custom field values (one to many), eager loads all custom fields
    # * categories (many to many)
    # * sections (many to one)
    #
    # The following plugins are loaded by this model
    #
    # * sluggable (source "title")
    # * timestamps
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class SectionEntry < Sequel::Model
      one_to_many(:comments, :class => "Comments::Model::Comment")

      one_to_many(
        :custom_field_values, 
        :class => "CustomFields::Model::CustomFieldValue", 
        :eager => [:custom_field]
      )
      
      many_to_one(:user       , :class => "Users::Model::User")
      many_to_many(:categories, :class => "Categories::Model::Category")
      many_to_one(:section    , :class => "Sections::Model::Section")
      
      plugin(:sluggable , :source => :title     , :freeze => false)
      plugin(:timestamps, :create => :created_at, :update => false)
      
      ##
      # Specify our validation rules.
      #
      # @author Yorick Peterse
      # @since  0.1
      # 
      def validate
        validates_presence([:title, :status, :user_id])
        validates_presence(:slug) unless new?

        # Check if the slug is unique for the current section
        if !SectionEntry.filter({:slug => slug, :section_id => section_id}, ~{:id => id}) \
          .all.empty?
          errors.add(:slug, lang('zen_models.unique'))
        end
      end
    end # SectionEntry
  end # Model
end # Sections
