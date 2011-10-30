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
#
# ## Models
#
# * {Comments::Model::Comment}
# * {Comments::Model::CommentStatus}
#
# ## Plugins
#
# * {Comments::Plugin::AntiSpam}
# * {Comments::Plugin::Comments}
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
    # ![Comments](../../_static/comments/comments.png)
    #
    # Comments can be edited by clicking on their name. Deleting comments can be
    # done by checking the checkboxes in each row followed by clicking the
    # "Delete selected comments" button.
    #
    # ## Editing Comments
    #
    # ![Edit Comment](../../_static/comments/edit_comment.png)
    #
    # When editing a comment you can specify/update the following fields:
    #
    # * **Name**: the name of the author. This field can only be changed if the
    #   comment was posted by somebody that wasn't logged in.
    # * **Website**: the website of the author that posted the comment.
    # * **Email**: the Email address of the author. If the comment was posted by
    #   a user that wasn't logged in then this field is required.
    # * **Status**: the status of a comment, can be "Open", "Closed" or "Spam".
    #   If the status is something other than "Open" it will be hidden when the
    #   comments plugin is used.
    # * **Comment** (required): the actual comment. Based on a section's
    #   settings these are formatted using Markdown, Textile or any of the other
    #   available markup processors.
    #
    # Note that if a comment was posted by a user that was logged in you won't
    # be able to change the name of the author.
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
    # ## Events
    #
    # All events called in this controller receive an instance of
    # {Comments::Model::Comment}. However, just like all other controllers the
    # ``delete_comment`` receives an instance of this model that has already
    # been destroyed.
    #
    # An example of using one of these events is to notify a user when his
    # comment has been marked as spam:
    #
    #     require 'mail'
    #
    #     Zen::Event.call(:after_edit_comment) do |comment|
    #       email = comment.user.email
    #       spam  = Comments::Model::CommentStatus[:name => 'spam']
    #
    #       if comment.comment_status_id == spam.id
    #         Mail.deliver do
    #           from    'example@domain.tld'
    #           to      email
    #           subject 'Your comment has been marked as spam'
    #           body    "Dear #{comment.user.name}, your comment has been " \
    #             "marked as spam"
    #        end
    #      end
    #    end
    #
    # @since  0.1
    # @map    /admin/comments
    # @event  before_edit_comment
    # @event  after_edit_comment
    # @event  beore_delete_comment
    # @event  after_delete_comment
    #
    class Comments < Zen::Controller::AdminController
      map    '/admin/comments'
      helper :comment
      title  'comments.titles.%s'

      csrf_protection :save, :delete

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
          ::Comments::Model::Comment.search(query)
        end

        @comments ||= ::Comments::Model::Comment.eager(:comment_status, :user)
        @comments   = paginate(@comments)
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

        @comment = flash[:form_data] || validate_comment(id)

        render_view(:form)
      end

      ##
      # Saves the changes made to an existing comment.
      #
      # @since      0.1
      # @permission edit_comment
      # @event      before_edit_comment
      # @event      after_edit_comment
      #
      def save
        authorize_user!(:edit_comment)

        # Copy the POST data so we can work with it without messing things up
        post = request.subset(
          :id,
          :user_id,
          :name,
          :website,
          :email,
          :comment,
          :comment_status_id,
          :section_entry_id
        )

        comment = validate_comment(post['id'])

        post.delete('id')

        begin
          post.each { |k, v| comment.send("#{k}=", v) }
          Zen::Event.call(:before_edit_comment, comment)

          comment.save
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, lang('comments.errors.save'))

          flash[:form_errors] = comment.errors
          flash[:form_data]   = comment

          redirect_referrer
        end

        Zen::Event.call(:after_edit_comment, comment)

        message(:success, lang('comments.success.save'))
        redirect(Comments.r(:edit, comment.id))
      end

      ##
      # Deletes a number of comments. The IDs of these comments should be
      # specified in the POSt array "comment_ids".
      #
      # @since      0.1
      # @permission delete_comment
      # @event      before_delete_comment
      # @event      after_delete_comment
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
          Zen::Event.call(:before_delete_comment, comment)

          begin
            comment.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('comments.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:after_delete_comment, comment)
        end

        message(:success, lang('comments.success.delete'))
        redirect_referrer
      end
    end # Comments
  end # Controller
end # Comments
