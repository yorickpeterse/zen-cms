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
      map '/admin/comments'
      
      trait :extension_identifier => 'com.zen.comments'
      
      include ::Comments::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond("The specified request can't be executed without a valid CSRF token", 401)
        end
      end
      
      ##
      # Constructor method that pre-loads several variables.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = '/admin/comments/save'
        @form_delete_url = '/admin/comments/delete'
        @comments_lang   = Zen::Language.load 'comments'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym

          if @comments_lang.titles.key? method 
            @page_title = @comments_lang.titles[method]
          end
        end
      end
    
      ##
      # Shows an overview of all posted comments along with their status,
      # author and so on.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @comments_lang.titles[:index]
        
        @comments = Comment.all
      end
      
      ##
      # Edits an existing comment based on the ID.
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the comment to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@comments_lang.titles[:index], "admin/comments"), @page_title
        
        @comment = Comment[id]
      end
      
      ##
      # Saves a comment based on the current POST data. Note that this
      # method won't create a new comment as this can't be done using the backend.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        # Copy the POST data so we can work with it without messing things up
        post = request.params.dup
       
        # Remove all empty fields
        post.each do |key, value|
          post.delete(key) if value.empty?
        end

        @comment = Comment[post["id"]]

        begin
          @comment.update(post)
          notification(:success, @comments_lang.titles[:index], @comments_lang.success[:save])
        rescue
          notification(:error, @comments_lang.titles[:index], @comments_lang.errors[:save])
          
          flash[:form_errors] = @comment.errors
        end
        
        # Redirect the user to the proper page.
        if @comment.id
          redirect "/admin/comments/edit/#{@comment.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Deletes a number of comments based on the comment IDs specified
      # in the POST array "comment_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        # Obviously we'll require some IDs
        if !request.params["comment_ids"] or request.params["comment_ids"].empty?
          notification(:error, @comments_lang.titles[:index], @comments_lang.errors[:no_delete])
          redirect_referrer
        end
        
        # Delete each section
        request.params["comment_ids"].each do |id|
          @comment = Comment[id]
          
          begin
            @comment.delete
            notification(:success, @comments_lang.titles[:index], @comments_lang.success[:delete] % id)
          rescue
            notification(:error, @comments_lang.titles[:index], @comments_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end 
  end
end
