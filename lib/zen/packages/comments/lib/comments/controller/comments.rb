module Comments
  module Controllers
    ##
    # Controller used for managing comments. Administrations can't actually
    # add new comments using the backend controller but can edit or delete them.
    # Comments can be submitted to any section entry as long as the section
    # allows it. When submitting a comment the user data such as the name and email
    # will be retrieved from either the users table (if the user is logged in) or
    # from the form that was submitted.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Comments < Zen::Controllers::AdminController
      include ::Comments::Models

      map '/admin/comments'
      trait :extension_identifier => 'com.zen.comments'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end
      
      ##
      # Constructor method that pre-loads several variables and language files.
      # The following language files are loaded:
      #
      # * comments
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = Comments.r(:save)
        @form_delete_url = Comments.r(:delete)
        
        Zen::Language.load('comments')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_s
          @page_title = lang("comments.titles.#{method}") rescue nil
        end
      end
    
      ##
      # Shows an overview of all posted comments along with their status,
      # author and so on.
      #
      # This method requires the following permissions:
      #
      # * read
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(lang('comments.titles.index'))
        
        @comments = Comment.all
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
      # @param  [Integer] id The ID of the comment to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('comments.titles.index'), Comments.r(:index)), 
          @page_title
        )

        if flash[:form_data]
          @comment = flash[:form_data]
        else
          @comment = Comment[id.to_i]
        end
      end
      
      ##
      # Saves a comment based on the current POST data. Note that this
      # method won't create a new comment as this can't be done using the backend.
      #
      # This method requires the following permissions:
      #
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        # Copy the POST data so we can work with it without messing things up
        post     = request.params.dup
        @comment = Comment[post['id'].to_i]

        begin
          @comment.update(post)
          notification(
            :success, 
            lang('comments.titles.index'), 
            lang('comments.success.save')
          )
        rescue
          notification(
            :error, 
            lang('comments.titles.index'), 
            lang('comments.errors.save')
          )
          
          flash[:form_errors] = @comment.errors
          flash[:form_data]   = @comment
        end
        
        # Redirect the user to the proper page.
        if @comment.id
          redirect(Comments.r(:edit, @comment.id))
        else
          redirect_referrer
        end
      end
      
      ##
      # Deletes a number of comments based on the comment IDs specified
      # in the POST array "comment_ids".
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        # Obviously we'll require some IDs
        if !request.params['comment_ids'] or request.params['comment_ids'].empty?
          notification(
            :error, 
            lang('comments.titles.index'),
            lang('comments.errors.no_delete')
          )

          redirect_referrer
        end
        
        # Delete each section
        request.params['comment_ids'].each do |id|
          begin
            Comment[id.to_i].destroy
            notification(
              :success, 
              lang('comments.titles.index'), 
              lang('comments.success.delete')
            )
          rescue
            notification(
              :error, 
              lang('comments.titles.index'), 
              lang('comments.errors.delete') % id
            )
          end
        end
        
        redirect_referrer
      end
    end 
  end
end
