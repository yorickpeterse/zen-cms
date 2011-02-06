module Comments
  module Controllers
    ##
    # Frontend controller for the comments system used for saving user-submitted comments.
    # When the anti-spam system is enabled Zen will use Defensio to check if the comment is
    # spam or ham.
    #
    # @author Yorick Peterse
    # @since  0.1
    # 
    class CommentsForm < Zen::Controllers::FrontendController
      include ::Comments::Models
      
      map '/comments_form'
      trait :extension_identifier => 'com.zen.comments'
      
      before_all do
        csrf_protection :save do
          respond(@zen_general_lang.errors[:csrf], 401)
        end
      end
      
      ##
      # Creates a new comment for the section entry. Once the comment has been saved
      # the user will be redirected back to the previous page.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        comments_lang = Zen::Language.load('comments')

        comment = Comment.new
        post    = request.params.dup
        entry   = ::Sections::Models::SectionEntry[h(post['section_entry']).to_i]
        
        # Remove empty values
        post.each { |k, v| post.delete(k) if v.empty? }
        
        if post.key?('user_id')
          comment.user_id = post['user_id']
        end
        
        # Set the comment data
        comment.comment = post['comment']
        
        if !post.key?('user_id')
          ['name', 'website', 'email'].each do |k|
            if post.key?(k)
              comment.send("#{k}=", post[k])
            end
          end
        end
        
        comment.section_entry_id = entry.id
        
        # Validate the section entry
        if entry.nil?
          flash[:error] = comments_lang.errors[:invalid_entry]
          redirect_referrer
        end
        
        section = entry.section
        
        # Comments allowed?
        if section.comment_allow == false
          flash[:error] = comments_lang.errors[:comments_not_allowed]
          redirect_referrer
        end
        
        # Comments require an account?
        if section.comment_require_account == true and session[:user].nil?
          flash[:error] = comments_lang.errors[:comments_require_account]
          redirect_referrer
        end
        
        # Require moderation?
        if section.comment_moderate == true
          comment.status = 'closed'
        end
        
        # Require anti-spam validation?
        if session[:settings][:enable_antispam] == '1'
          # Validate the comment
          api_key = session[:settings][:defensio_key]
          
          if api_key.nil?
            flash[:error] = comments_lang.errors[:no_api_key]
            redirect_referrer
          end
          
          defensio         = ::Defensio.new(api_key)
          status, response = defensio.post_document(
            :content       => post['comment'],
            :platform      => "zen",
            :type          => "comment"
          )
          
          if status != 200
            flash[:error] = comments_lang.errors[:defensio_status]
            redirect_referrer
          end
          
          # Time to validate the Defensio response
          if response['allow'] == true and response['spaminess'] <= 0.85
            if section.comment_moderate == true
              comment.status = 'closed'
            else
              comment.status = 'open'
            end
            
            comment.defensio_signature = response['signature']
          else
            comment.status = 'spam'
          end
        end
        
        # Save the comment
        begin
          comment.save
          
          if section.comment_moderate == true
            flash[:success] = comments_lang.success[:moderate]
          else
            flash[:success] = comments_lang.success[:new]
          end
        rescue
          flash[:error]   = comments_lang.errors[:new]
        end
        
        redirect_referrer
      end
    end
  end
end
