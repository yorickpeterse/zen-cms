module Sections
  module Controller
    ##
    # In Zen a section entry's data is saved as a separate revision each time
    # you save it manually or when it's saved automatically (every 10 minutes).
    # Storing entries in separate revisions means you're able to revert to
    # specific revisions by simply clicking the "Restore" link for a specific
    # revision. No longer do you have to worry about accidently removing data
    # without being able to easily revert that change.
    #
    # Revisions can be viewed as well as being restored by clicking on the
    # "Revisions" link in the section entries overview. Once you've clicked this
    # link you'll be presented with an overview similar to this one:
    #
    # ![Revisions Overview](../../images/sections/revisions.png)
    #
    # This overview lets you compare two revisions as well as restoring
    # revisions.
    #
    # ## Comparing Revisions
    #
    # Comparing revisions makes it easy to see what has changed between two
    # given revisions. In order to compare two revisions you must select the
    # old and the new revision to compare. This can be done by checking the
    # checkboxes in the "Old" and "New" column for the revisions you want to
    # compare. Once you've selected the two revisions and have clicked on the
    # "Compare" button you'll be presented with a set of differences between the
    # two revisions.
    #
    # ![Revision Differences](../../images/sections/revisions_diff.png)
    #
    # Each field that had its value changed will be displayed with the changed
    # data next to it. When showing such differences the following information
    # is available for each field:
    #
    # * The line numbers of the old and new data. The numbers on the left are
    #   the old line numbers, the numbers on the right are the line numbers for
    #   the new revision.
    # * Lines that were deleted. These are displayed in red and are prefixed
    #   with a minus (`-`) sign.
    # * Lines that were added. These lines are displayed in green and are
    #   prefixed with a plus (`+`) sign.
    #
    # In case of the image above this means that line 1 was not changed and that
    # lines 2 and 3 were added in the revision selected in the "New" column.
    #
    # A more expanded example of comparing differences between revisions:
    #
    # ![Revision Differences With Multiple Fields]
    # (../../images/sections/revisions_diff_multiple.png)
    #
    # This example shows the result of comparing two revisions that contain
    # changes for multiple custom fields.
    #
    # <div class="note todo">
    #     <p>
    #         <strong>Note:</strong>
    #         If there are no differences between a revision a notice will be
    #         displayed instead of the set of changes.
    #     </p>
    # </div>
    #
    # ## Restoring Revisions
    #
    # Restoring revisions makes it easy to revert a set of changes without
    # having to manually make these changes to a section entry, or worse: fiddle
    # around with database backups.
    #
    # Restoring revisions is quite easy, once you've decided which revision you
    # want to restore all you need to do is click the "Restore" link of the
    # specific revision. Restoring a revision will result in the following two
    # actions:
    #
    # * The revision ID of the entry is set to the ID of the revision you want
    #   to restore.
    # * All newer revisions are deleted.
    #
    # ## Revision Limit
    #
    # Every time a section entry is saved a new revision will be created. To
    # prevent the revisions table from filling up with thousands of revisions
    # these revisions will be removed after a certain number has been exceeded.
    #
    # By default the oldest revision will be removed if there are more than 10
    # revisions for a section entry. This limit can be changed by going to the
    # settings manager. For more information about using the settings manager
    # refer to {Settings::Controller::Settings Managing Settings}.
    #
    # @since 2012-04-30
    # @map   /admin/revisions
    #
    class Revisions < Zen::Controller::AdminController
      map    '/admin/revisions'
      title  'revisions.titles.%s'
      helper :section, :revision

      ##
      # Shows an overview of the revisions for a given section entry ID.
      #
      # @since 2012-04-30
      # @param [Fixnum|String] section_id The ID of the section the entry
      #  belongs to.
      # @param [Fixnum|String] id The ID of the section entry for which to show
      #  the revisions.
      # @permission show_revision
      #
      def index(section_id, id)
        authorize_user!(:show_revision)

        validate_section(section_id)

        @entry     = validate_section_entry(id, section_id)
        @revisions = @entry.revisions
        @entry_url = SectionEntries.a(
          @entry.title,
          :edit,
          @entry.section_id,
          @entry.id
        )

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
          lang('revisions.titles.index')
        )
      end

      ##
      # Sets the revision ID of a section entry to a specific revision, deleting
      # newer revisions.
      #
      # @since 2012-05-03
      # @param [Fixnum|String] revision_id The ID of the revision to restore.
      # @permission restore_revision
      #
      def restore(revision_id)
        authorize_user!(:restore_revision)

        revision = validate_revision(revision_id)

        if revision
          entry = revision.section_entry

          begin
            entry.update(:revision_id => revision.id)
          rescue => e
            Ramaze::Log.error(e)

            message(:error, lang('revisions.errors.restore'))
            redirect_referer
          end

          begin
            Model::Revision \
              .filter(:section_entry_id => entry.id) { id > revision.id } \
              .delete

            message(:success, lang('revisions.success.restore'))
          rescue => e
            Ramaze::Log.error(e)

            message(:error, lang('revisions.errors.restore'))
          end

          redirect_referer
        end
      end
    end # Revisions
  end # Controller
end # Sections
