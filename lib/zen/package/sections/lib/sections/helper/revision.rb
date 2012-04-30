module Ramaze
  module Helper
    ##
    # Helper for the controller {Sections::Controller::Revisions}.
    #
    # @since 30-04-2012
    #
    module Revision
      ##
      # Generates the breadcrumb segment for a revision title.
      #
      # @since  30-04-2012
      # @param  [String] title The title of the entry.
      # @return [String]
      #
      def revision_breadcrumb(title)
        if title.length > 12
          return title[0..12] + '...'
        else
          return title
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
        old_values = entry.custom_fields_and_values(old_revision)
        new_values = entry.custom_fields_and_values(new_revision)
        diff       = {}

        old_values.each do |field_id, hash|
          new_hash = new_values[field_id]

          diff[hash[:name]] = Differ.diff(new_hash[:value], hash[:value]) \
            .format_as(Zen::Differ::PrettyHTML)
        end

        return diff
      end
    end # Revision
  end # Helper
end # Ramaze
