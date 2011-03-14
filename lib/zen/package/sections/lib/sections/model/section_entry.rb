#:nodoc:
module Sections
  #:nodoc:
  module Models
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
      one_to_many(
        :comments, 
        :class => "Comments::Models::Comment"
      )

      one_to_many(
        :custom_field_values, 
        :class => "CustomFields::Models::CustomFieldValue", 
        :eager => [:custom_field]
      )
      
      many_to_one(:user       , :class => "Users::Models::User")
      many_to_many(:categories, :class => "Categories::Models::Category")
      many_to_one(:section    , :class => "Sections::Models::Section")
      
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
      end
    end
  end
end
