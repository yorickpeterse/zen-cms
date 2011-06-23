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
      one_to_many(
        :comments, 
        :class => "Comments::Model::Comment"
      )

      one_to_many(
        :custom_field_values, 
        :class => "CustomFields::Model::CustomFieldValue", 
        :eager => [:custom_field]
      )
      
      many_to_one(
        :user, 
        :class => "Users::Model::User"
      )
      
      many_to_many(
        :categories, 
        :class => "Categories::Model::Category"
      )
      
      many_to_one(
        :section, 
        :class => "Sections::Model::Section"
      )

      many_to_one(
        :section_entry_status, 
        :class => 'Sections::Model::SectionEntryStatus'
      )
      
      plugin(:sluggable , :source => :title     , :freeze => false)
      plugin(:timestamps, :create => :created_at, :update => false)
      
      ##
      # Specify our validation rules.
      #
      # @author Yorick Peterse
      # @since  0.1
      # 
      def validate
        validates_presence([:title, :user_id])
        validates_presence(:slug) unless new?
        validates_integer(:section_entry_status_id)

        # Check if the slug is unique for the current section
        if !SectionEntry \
        .filter({:slug => slug, :section_id => section_id}, ~{:id => id}) \
        .all.empty?
          errors.add(:slug, lang('zen_models.unique'))
        end
      end

      ##
      # Returns a hash containing all the entry statuses. The keys of this hash
      # are the IDs and the values the names. 
      #
      # @author Yorick Peterse
      # @since  0.2.7.1
      # @return [Hash]
      #
      def self.status_hash
        ::Zen::Language.load('section_entries')

        statuses = {}

        ::Sections::Model::SectionEntryStatus.all.each do |status|
          statuses[status.id] = lang(
            "section_entries.special.status_hash.#{status.name}"
          )
        end

        return statuses
      end

      ##
      # Hook that is executed before saving an existing section entry.
      #
      # @author Yorick Peterse
      # @since  0.2.7.1
      #
      def before_save
        if self.section_entry_status_id.nil?
          self.section_entry_status_id = ::Sections::Model::SectionEntryStatus[
            :name => 'draft'
          ].id
        end

        super
      end
    end # SectionEntry
  end # Model
end # Sections
