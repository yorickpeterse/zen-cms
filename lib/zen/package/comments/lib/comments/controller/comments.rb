##
# Package that allows users to manage and submit comments.
#
# ## Controllers
#
# * {Comments::Controller::Comments}
# * {Comments::Controller::CommentsForm}
#
# ## Helpers
#
# * {Ramaze::Helper::Comment}
# * {Ramaze::Helper::CommentFrontend}
#
# ## Models
#
# * {Comments::Model::Comment}
# * {Comments::Model::CommentStatus}
#
# ## Generic Modules & Classes
#
# * {Comments::AntiSpam}
#
# @since  0.1
#
module Comments
  #:nodoc:
  module Controller
    ##
    # Controller for managing existing comments. When logged in a user can not
    # add a comment, for that they'd have to use the frontend.
    #
    # Depending on the settings of a section the comments belong to (via a
    # section entry) users may have to meet certain requirements in order to be
    # able to post a comment. For example, a section might require users to be
    # logged in in order to post comments. If this is the case and the user
    # tries to submit a comment a message will be displayed and the HTTP status
    # code is changed to 403. See {Comments::Controller::CommentsForm} for more
    # information.
    #
    # In order to manage existing comments you'll have to navigate to
    # ``/admin/comments``. This page will show an overview of all existing
    # comments (or a message if no comments were found).
    #
    # ![Comments](../../images/comments/comments.png)
    #
    # Comments can be edited by clicking on their name. Deleting comments can be
    # done by checking the checkboxes in each row followed by clicking the
    # "Delete selected comments" button.
    #
    # ## Editing Comments
    #
    # ![Edit Comment](../../images/comments/edit_comment.png)
    #
    # When editing a comment you can specify/update the following fields:
    #
    # <table class="table full">
    #     <thead>
    #         <tr>
    #             <th class="field_name">Field</th>
    #             <th>Required</th>
    #             <th>Maximum Length</th>
    #             <th>Description</th>
    #         </tr>
    #     </thead>
    #     <tbody>
    #         <tr>
    #             <td>Name</td>
    #             <td>
    #                 Only when the comment was submitted by a non logged in
    #                 user.
    #             </td>
    #             <td>255</td>
    #             <td>
    #                 The name of the author of the comment. This field can only
    #                 be edited if the comment was submitted by a user that
    #                 wasn't logged in.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Website</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>The website of the comment author.</td>
    #         </tr>
    #         <tr>
    #             <td>Email</td>
    #             <td>
    #                 Only if the comment was submitted by a user that wasn't
    #                 logged in.
    #             </td>
    #             <td>255</td>
    #             <td>
    #                 The Email address of the comment author. Like the name
    #                 field this field can only be edited if the comment was
    #                 submitted by a user that wasn't logged in.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Status</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 The status of the comment. If a comment is created and no
    #                 status is specified the status will be set to "closed".
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Comment</td>
    #             <td>Yes</td>
    #             <td>Unlimited</td>
    #             <td>The actual comment.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_comment
    # * edit_comment
    # * new_comment
    # * delete_comment
    #
    # @since  0.1
    # @map    /admin/comments
    #
    class Comments < Zen::Controller::AdminController
      map    '/admin/comments'
      helper :comment
      title  'comments.titles.%s'

      csrf_protection :save, :delete

      autosave Model::Comment, Model::Comment::COLUMNS, :edit_comment

      ##
      # Shows an overview of all existing comments and allows the user to edit
      # or remove these comments.
      #
      # @since      0.1
      # @permission show_comment
      #
      def index
        authorize_user!(:show_comment)

        set_breadcrumbs(lang('comments.titles.index'))

        @comments = search do |query|
          ::Comments::Model::Comment.search(query).order(:comments__id.asc)
        end

        @comments ||= ::Comments::Model::Comment \
          .eager(:comment_status, :user) \
          .order(:id.asc)

        @comments = paginate(@comments)
      end

      ##
      # Allows a user to edit an existing comment.
      #
      # @param      [Fixnum] id The ID of the comment to edit.
      # @since      0.1
      # @permission edit_comment
      #
      def edit(id)
        authorize_user!(:edit_comment)

        set_breadcrumbs(
          Comments.a(lang('comments.titles.index'), :index),
          @page_title
        )

        @comment = validate_comment(id)
        @comment.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves the changes made to an existing comment.
      #
      # @since      0.1
      # @permission edit_comment
      #
      def save
        authorize_user!(:edit_comment)

        post    = post_fields(*Model::Comment::COLUMNS)
        comment = validate_comment(request.params['id'])

        begin
          comment.set(post)
          comment.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, lang('comments.errors.save'))

          flash[:form_errors] = comment.errors
          flash[:form_data]   = post

          redirect_referrer
        end

        message(:success, lang('comments.success.save'))
        redirect(Comments.r(:edit, comment.id))
      end

      ##
      # Deletes a number of comments. The IDs of these comments should be
      # specified in the POSt array "comment_ids".
      #
      # @since      0.1
      # @permission delete_comment
      #
      def delete
        authorize_user!(:delete_comment)

        # Obviously we'll require some IDs
        if !request.params['comment_ids'] \
        or request.params['comment_ids'].empty?
          message(:error, lang('comments.errors.no_delete'))
          redirect_referrer
        end

        # Delete each section
        request.params['comment_ids'].each do |id|
          comment = ::Comments::Model::Comment[id]

          next if comment.nil?

          begin
            comment.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('comments.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('comments.success.delete'))
        redirect_referrer
      end
    end # Comments
  end # Controller
end # Comments
