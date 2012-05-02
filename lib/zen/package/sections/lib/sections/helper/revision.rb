module Ramaze
  module Helper
    ##
    # Helper for the controller {Sections::Controller::Revisions}.
    #
    # @since 30-04-2012
    #
    module Revision
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
        if rev_id.to_i == current_rev_id.to_i
          return '<input name="old_revision_id"' \
            "value=\"#{rev_id}\" type=\"radio\" checked=\"checked\" />"
        else
          return '<input name="old_revision_id"' \
            "value=\"#{rev_id}\" type=\"radio\" />"
        end
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
        if rev_id.to_i == current_rev_id.to_i
          return '<input name="new_revision_id"' \
            "value=\"#{rev_id}\" type=\"radio\" checked=\"checked\" />"
        else
          return '<input name="new_revision_id"' \
            "value=\"#{rev_id}\" type=\"radio\" />"
        end
      end
    end # Revision
  end # Helper
end # Ramaze
