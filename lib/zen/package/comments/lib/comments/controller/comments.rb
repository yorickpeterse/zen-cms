#:nodoc:
module Comments
  #:nodoc:
  module Controller
    ##
    # Controller used for managing comments. Administrations can't actually add
    # new comments using the backend controller but can edit or delete them.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Comments < Zen::Controller::AdminController
      map '/admin/comments'
      helper :comment

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Creates a new instance of the controller.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        @page_title = lang("comments.titles.#{action.method}") rescue nil
      end

      ##
      # Shows an overview of all posted comments along with their status, author
      # and so on.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        require_permissions(:read)

        set_breadcrumbs(lang('comments.titles.index'))

        @comments = paginate(
          ::Comments::Model::Comment.eager(:comment_status)
        )
      end

      ##
      # Edits an existing comment based on the ID.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the comment to edit.
      # @since  0.1
      #
      def edit(id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          Comments.a(lang('comments.titles.index'), :index),
          @page_title
        )

        if flash[:form_data]
          @comment = flash[:form_data]
        else
          @comment = validate_comment(id)
        end

        render_view(:form)
      end

      ##
      # Saves a comment based on the current POST data. Note that this method
      # won't create a new comment as this can't be done using the backend.
      #
      # This method requires the following permissions:
      #
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        require_permissions(:update)

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
          message(:success, lang('comments.success.save'))
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, lang('comments.errors.save'))

          flash[:form_errors] = comment.errors
          flash[:form_data]   = comment

          redirect_referrer
        end

        # Redirect the user to the proper page.
        if comment.id
          redirect(Comments.r(:edit, comment.id))
        else
          redirect_referrer
        end
      end

      ##
      # Deletes a number of comments based on the comment IDs specified in the
      # POST array "comment_ids".
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        require_permissions(:delete)

        # Obviously we'll require some IDs
        if !request.params['comment_ids'] \
        or request.params['comment_ids'].empty?
          message(:error, lang('comments.errors.no_delete'))
          redirect_referrer
        end

        # Delete each section
        request.params['comment_ids'].each do |id|
          begin
            ::Comments::Model::Comment[id].destroy
            message(:success, lang('comments.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('comments.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # Comments
  end # Controller
end # Comments
