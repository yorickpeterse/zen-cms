module Sections
  module Model
    ##
    # Model for storing section entry revisions and linking these to custom
    # field values.
    #
    # @since 29-04-2012
    #
    class Revision < Sequel::Model
      many_to_one :section_entry,
        :class => 'Sections::Model::SectionEntry'

      many_to_one :user,
        :class => 'Users::Model::User'

      one_to_many :custom_field_values,
        :class => 'CustomFields::Model::CustomFieldValue'

      plugin :timestamps, :create => :created_at

      plugin :association_dependencies,
        :custom_field_values => :delete

      ##
      # Hook executed before inserting a new row. This hook is used to purge
      # for a section entry if the amount of revisions for such an entry exceeds
      # the maximum amount.
      #
      # @since 01-05-2012
      #
      def before_create
        amount = Revision.filter(:section_entry_id => section_entry_id).count
        max    = get_setting(:maximum_revisions).value.to_i

        if amount >= max
          Revision.filter(:section_entry_id => section_entry_id) \
            .order(:id.asc) \
            .first \
            .delete
        end

        super
      end

      ##
      # Hook that is executed before deleting the revision. This hook is used to
      # prevent the last revision of an entry from being deleted.
      #
      # @since 29-04-2012
      #
      def before_destroy
        entry = section_entry
        _id   = id

        # Set the revision ID of the entry to the previous revision.
        if entry.revision_id == _id
          prev_revision = Revision \
            .filter(:section_entry_id => entry.id) { id < _id } \
            .limit(1) \
            .first

          if prev_revision and prev_revision
            entry.update(:revision_id => prev_revision.id)
          else
            raise(
              Sequel::Error::InvalidOperation,
              'You can not delete the last revision'
            )
          end
        end

        super
      end
    end # Revision
  end # Model
end # Sections
