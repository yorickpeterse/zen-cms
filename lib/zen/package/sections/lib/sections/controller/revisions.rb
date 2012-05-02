module Sections
  module Controller
    ##
    # Controller for managing the revisions of a section entry.
    #
    # @since 30-04-2012
    # @map   /admin/revisions
    #
    class Revisions < Zen::Controller::AdminController
      map    '/admin/revisions'
      title  'revisions.titles.%s'
      helper :section, :revision

      ##
      # Shows an overview of the revisions for a given section entry ID.
      #
      # @since 30-04-2012
      # @param [Fixnum] section_id The ID of the section the entry belongs to.
      # @param [Fixnum] id The ID of the section entry for which to show the
      #  revisions.
      # @permission show_revision
      #
      def index(section_id, id)
        authorize_user!(:show_revision)

        @entry     = validate_section_entry(id, section_id)
        @revisions = @entry.revisions

        # Compare two revisions if both IDs are specified.
        if request.POST['old_revision_id'] and request.POST['new_revision_id']
          @old_rev_id = request.POST['old_revision_id']
          @new_rev_id = request.POST['new_revision_id']
          @diff       = revision_diff(@entry, @old_rev_id, @new_rev_id)
        end

        set_breadcrumbs(
          Sections.a(
            lang('sections.titles.index'),
            :index
          ),
          SectionEntries.a(
            lang('section_entries.titles.index'),
            :index,
            section_id
          ),
          'Revisions'
        )
      end
    end # Revisions
  end # Controller
end # Sections
