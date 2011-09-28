#:nodoc:
module Comments
  #:nodoc:
  module Controller
    ##
    # Controller for managing existing comments. When logged in a user can not
    # add a comment, for that they'd have to use the frontend.
    #
    # ## Used Permissions
    #
    # * show_comment
    # * edit_comment
    # * new_comment
    # * delete_comment
    #
    # ## Available Events
    #
    # * edit_comment
    # * delete_comment
    #
    # @author  Yorick Peterse
    # @since   0.1
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_comment)

        set_breadcrumbs(lang('comments.titles.index'))

        @comments = paginate(::Comments::Model::Comment.eager(:comment_status))
      end

      ##
      # Allows a user to edit an existing comment.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the comment to edit.
      # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
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
          comment.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, lang('comments.errors.save'))

          flash[:form_errors] = comment.errors
          flash[:form_data]   = comment

          redirect_referrer
        end

        Zen::Event.call(:edit_comment, comment)

        message(:success, lang('comments.success.save'))
        redirect(Comments.r(:edit, comment.id))
      end

      ##
      # Deletes a number of comments. The IDs of these comments should be
      # specified in the POSt array "comment_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
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
            Ramaze::Log.error(e.inspect)
            message(:error, lang('comments.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_comment, comment)
        end

        message(:success, lang('comments.success.delete'))
        redirect_referrer
      end
    end # Comments
  end # Controller
end # Comments
