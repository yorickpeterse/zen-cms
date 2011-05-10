#:nodoc:
module Comments
  #:nodoc:
  module Controller
    ##
    # Frontend controller for the comments system used for saving user-submitted comments.
    # When the anti-spam system is enabled Zen will use Defensio to check if the comment is
    # spam or ham.
    #
    # @author Yorick Peterse
    # @since  0.1
    # 
    class CommentsForm < Zen::Controller::FrontendController
      include ::Comments::Model
      
      map('/comments-form')
      
      before_all do
        csrf_protection(:save) do
          respond(lang('zen_general.errors.not_authorized'), 403)
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
        Zen::Language.load('comments')

        comment = Comment.new
        post    = request.params.dup
        entry   = ::Sections::Model::SectionEntry[h(post['section_entry']).to_i]
        
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
          flash[:error] = lang('comments.errors.invalid_entry')
          redirect_referrer
        end
        
        section = entry.section
        
        # Comments allowed?
        if section.comment_allow == false
          flash[:error] = lang('comments.errors.comments_not_allowed')
          redirect_referrer
        end
        
        # Comments require an account?
        if section.comment_require_account == true and session[:user].nil?
          flash[:error] = lang('comments.errors.comments_require_account')
          redirect_referrer
        end
        
        # Require moderation?
        if section.comment_moderate == true
          comment.status = 'closed'
        end
        
        # Require anti-spam validation?
        if ::Zen::Settings[:enable_antispam] == '1'
          engine       = ::Zen::Settings[:defensio_key].to_sym
          status, spam = plugin(:anti_spam, engine, nil, nil, nil, post['comment'])
          
          if status != 200
            flash[:error] = lang('comments.errors.defensio_status')
            redirect_referrer
          end
          
          # Time to validate the Defensio response
          if spam === false
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
            flash[:success] = lang('comments.success.moderate')
          else
            flash[:success] = lang('comments.success.new')
          end
        rescue
          flash[:error] = lang('comments.errors.new')
        end
        
        redirect_referrer
      end
    end
  end
end
