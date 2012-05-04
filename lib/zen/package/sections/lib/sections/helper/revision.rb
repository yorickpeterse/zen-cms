module Ramaze
  module Helper
    ##
    # Helper for the controller {Sections::Controller::Revisions}.
    #
    # @since 30-04-2012
    #
    module Revision
      ##
      # Validates a revision ID. If the ID is invalid the user will be
      # redirected back to the previous page and a message will be displayed.
      #
      # If the revision ID resulted in a valid Revision object then that object
      # is returned.
      #
      # @since  05-05-2012
      # @param  [Fixnum|String] revision_id The ID of the revision.
      # @return [Sections::Model::Revision]
      #
      def validate_revision(revision_id)
        unless revision_id =~ /\d+/
          message(:error, lang('revisions.errors.invalid'))
          redirect_referer
        end

        revision = Sections::Model::Revision[revision_id]

        if revision
          return revision
        else
          message(:error, lang('revisions.errors.invalid'))
          redirect_referer
        end
      end

      ##
      # Returns a hash containing the difference between the values of two
      # section entries.
      #
      # @since 30-04-2012
      # @param  [Sections::Model::SectionEntry] entry The entry for which to
      #  generate the diff.
      # @param  [Fixnum|String] old_revision The old revision ID.
      # @param  [Fixnum|String] new_revision The new revision ID.
      # @return [Hash]
      #
      def revision_diff(entry, old_revision, new_revision)
        validate_revision(old_revision)
        validate_revision(new_revision)

        old_values = entry.custom_fields_and_values(old_revision)
        new_values = entry.custom_fields_and_values(new_revision)
        diff       = {}

        old_values.each do |field_id, hash|
          new_hash = new_values[field_id]

          if hash[:value] != new_hash[:value]
            diff[hash[:name]] = Zen::HTMLDiff.diff(
              hash[:value],
              new_hash[:value]
            )
          end
        end

        return diff
      end

      ##
      # Generates a radio button for an old revision ID.
      #
      # @since  01-05-2012
      # @param  [Fixnum|String] rev_id The revision ID.
      # @param  [Fixnum|String] current_rev_id The currently active old revision
      #  ID.
      # @return [String]
      #
      def old_revision_radio(rev_id, current_rev_id)
        g     = Ramaze::Gestalt.new
        attrs = {
          :name  => 'old_revision_id',
          :id    => "old_revision_id_#{rev_id}",
          :type  => 'radio',
          :value => rev_id
        }

        if rev_id.to_i == current_rev_id.to_i
          attrs[:checked] = 'checked'
        end

        g.input(attrs)

        return g.to_s
      end

      ##
      # Generates a radio button for a new revision ID.
      #
      # @since  01-05-2012
      # @param  [Fixnum|String] rev_id The revision ID.
      # @param  [Fixnum|String] current_rev_id The currently active new revision
      #  ID.
      # @return [String]
      #
      def new_revision_radio(rev_id, current_rev_id)
        g     = Ramaze::Gestalt.new
        attrs = {
          :name  => 'new_revision_id',
          :id    => "new_revision_id_#{rev_id}",
          :type  => 'radio',
          :value => rev_id
        }

        if rev_id.to_i == current_rev_id.to_i
          attrs[:checked] = 'checked'
        end

        g.input(attrs)

        return g.to_s
      end
    end # Revision
  end # Helper
end # Ramaze
