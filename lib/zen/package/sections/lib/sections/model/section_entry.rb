module Sections
  #:nodoc:
  module Model
    ##
    # Model that represents a singe section entry.
    #
    # @since 0.1
    # @event before_new_section_entry
    # @event after_new_section_entry
    # @event before_edit_section_entry
    # @event after_edit_section_entry
    # @event before_delete_section_entry
    # @event after_delete_section_entry
    #
    class SectionEntry < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing all the columns that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [
        :title,
        :created_at,
        :section_id,
        :user_id,
        :slug,
        :section_entry_status_id,
        :category_pks
      ]

      one_to_many :comments,
        :class => 'Comments::Model::Comment'

      one_to_many :custom_field_values,
        :class => 'CustomFields::Model::CustomFieldValue',
        :eager => [:custom_field]

      many_to_one :user,
        :class => 'Users::Model::User'

      many_to_many :categories,
        :class => 'Categories::Model::Category'

      many_to_one :section,
        :class => 'Sections::Model::Section'

      many_to_one :section_entry_status,
        :class => 'Sections::Model::SectionEntryStatus'

      plugin :sluggable , :source => :title     , :freeze => false
      plugin :timestamps, :create => :created_at, :update => :updated_at

      plugin :association_dependencies,
        :comments            => :delete,
        :custom_field_values => :delete

      plugin :events,
        :before_create  => :before_new_section_entry,
        :after_create   => :after_new_section_entry,
        :before_update  => :before_edit_section_entry,
        :after_update   => :after_edit_section_entry,
        :before_destroy => :before_delete_section_entry,
        :after_destroy  => :after_delete_section_entry

      # String containing the date format to use for the created_at field when
      # rendering the form.
      DATE_FORMAT = '%Y-%m-%d %H:%M'

      # A hash that will contain all the custom fields and the values of these
      # fields for a single entry.
      attr_accessor :fields

      ##
      # Searches for a set of section entries based on the specified search
      # query.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:title, query))
      end

      ##
      # Specify our validation rules.
      #
      # @since  0.1
      #
      def validate
        validates_presence([:title, :user_id])
        validates_integer(:section_entry_status_id)

        validates_max_length(255, [:title, :slug])

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
      # @since  0.2.8
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
      # Retrieves all custom fields for a section entry.
      #
      # @since  0.2.8
      # @return [Array]
      #
      def custom_fields
        return CustomFields::Model::CustomField.select_all(:custom_fields) \
          .join(
            :custom_field_groups,
            :custom_field_groups__id => :custom_fields__custom_field_group_id
          ) \
          .join(
            :custom_field_groups_sections,
            :custom_field_groups_sections__custom_field_group_id \
              => :custom_field_groups__id
          ) \
          .filter(
            :custom_field_groups_sections__section_id => section_id
          ) \
          .all
      end

      ##
      # Retrieves all the possible categories for an entry and returns these as
      # a hash. This hash is a multi dimensional hash where the keys are the
      # names of all available category groups and the values hashes with the
      # IDs and names of all the categories for that group.
      #
      # @example
      #  e = Sections::Model::SectionEntry[1]
      #  e.possible_categories # => {'Blog' => {1 => 'General', 2 => 'Code'}}
      #
      # @since  0.2.8
      # @return [Hash]
      #
      def possible_categories
        hash  = {}
        query = Zen.database[:category_groups_sections] \
          .select(
            :categories__id,
            :categories__name,
            :category_groups__name => :category_group_name
          ) \
          .left_join(
            :categories,
            :category_groups_sections__category_group_id \
              => :categories__category_group_id
          ) \
          .left_join(
            :category_groups,
            :category_groups_sections__category_group_id => :category_groups__id
          ) \
          .filter(
            :category_groups_sections__section_id => section_id
          ) \
          .all

        query.each do |row|
          hash[row[:category_group_name]]           ||= {}
          hash[row[:category_group_name]][row[:id]]   = row[:name]
        end

        return hash
      end

      ##
      # Gathers all the custom field groups, custom fields and custom field
      # values and returns them as a hash. This hash can be used in views to
      # build the HTML for all the fields.
      #
      # @since  0.2.8
      # @return [Hash]
      #
      def custom_fields_hash
        result    = {}
        values    = {}
        groups    = section.custom_field_groups
        group_ids = groups.map { |g| g.id }
        fields    = {}

        # Get all the custom fields in one go rather than running a query for
        # each group.
        CustomFields::Model::CustomField.filter(
          :custom_field_group_id => group_ids
        ).each do |field|
          fields[field.custom_field_group_id] ||= []
          fields[field.custom_field_group_id].push(field)
        end

        # Index the custom field values hash so that the keys are the IDs of the
        # custom fields and the values the instances of
        # CustomFields::Model::CustomFieldValue.
        custom_field_values.each do |val|
          values[val.custom_field_id] = val
        end

        # Build the hash containing all the details of each field
        groups.each do |group|
          result[group.id] ||= {:name => group.name, :fields => []}

          # Don't process the fields if there aren't any to begin with.
          next unless fields.key?(group.id)

          fields[group.id].each do |field|
            m = field.custom_field_type.custom_field_method.name

            begin
              result[group.id][:fields].push(
                CustomFields::BlueFormParameters.send(
                  m, field, values[field.id]
                )
              )
            rescue => e
              Ramaze::Log.error(e)
            end
          end
        end

        return result
      end

      ##
      # Returns a string containing the name of the entry's status in the
      # currently used language.
      #
      # @since  17-12-2011
      # @return [String]
      #
      def status_name
        return lang(
          'section_entries.special.status_hash.%s' % section_entry_status.name
        )
      end

      ##
      # Hook that is executed before saving an existing section entry.
      #
      # @since  0.2.8
      #
      def before_save
        sanitize_fields([:title, :slug])

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
