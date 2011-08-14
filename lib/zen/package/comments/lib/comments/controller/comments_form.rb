#:nodoc:
module Comments
  #:nodoc:
  module Controller
    ##
    # Frontend controller for the comments system used for saving user-submitted
    # comments.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CommentsForm < Zen::Controller::FrontendController
      map '/comments-form'
      helper :message

      before_all do
        csrf_protection(:save) do
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
      end

      ##
      # Creates a new comment for the section entry. Once the comment has been
      # saved the user will be redirected back to the previous page.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        Zen::Language.load('comments')

        comment = ::Comments::Model::Comment.new
        post    = request.subset(
          :section_entry,
          :user_id,
          :comment,
          :name,
          :website,
          :email
        )

        # Get all the comment statuses.
        comment_statuses = {}
        draft_status     = ::Sections::Model::SectionEntryStatus[
          :name => 'draft'
        ].id

        ::Comments::Model::CommentStatus.all.each do |status|
          comment_statuses[status.name] = status.id
        end

        entry = ::Sections::Model::SectionEntry[post['section_entry']]

        # Remove empty values
        post.each { |k, v| post.delete(k) if v.empty? }

        comment.user_id = post['user_id'] if post.key?('user_id')
        comment.comment = post['comment']

        # If no user ID is specified we'll use the name, website and Email of
        # the POST data.
        if !post.key?('user_id')
          ['name', 'website', 'email'].each do |k|
            if post.key?(k)
              comment.send("#{k}=", post[k])
            end
          end
        end

        # Validate the section entry
        if entry.nil? or entry.section_entry_status_id === draft_status
          message(:error, lang('comments.errors.invalid_entry'))
          redirect_referrer
        end

        comment.section_entry_id = entry.id
        section                  = entry.section

        # Section valid?
        if section.nil?
          message(:error, lang('comments.errors.invalid_entry'))
          redirect_referrer
        end

        # Comments allowed?
        if section.comment_allow === false
          message(:error, lang('comments.errors.comments_not_allowed'))
          redirect_referrer
        end

        # Comments require an account?
        if section.comment_require_account === true and session[:user].nil?
          message(:error, lang('comments.errors.comments_require_account'))
          redirect_referrer
        end

        # Require moderation?
        if section.comment_moderate === true
          comment.comment_status_id = comment_statuses['closed']
        end

        # Require anti-spam validation?
        if plugin(:settings, :get, :enable_antispam).value === '1'
          engine = plugin(:settings, :get, :anti_spam_system).value.to_sym
          spam   = plugin(:anti_spam, engine, nil, nil, nil, post['comment'])

          # Time to validate the Defensio response
          if spam === false
            if section.comment_moderate == true
              comment.comment_status_id = comment_statuses['closed']
            else
              comment.comment_status_id = comment_statuses['open']
            end
          else
            comment.comment_status_id = comment_statuses['spam']
          end
        end

        # Save the comment
        begin
          comment.save
          Zen::Hook.call(:new_comment, comment)

          if section.comment_moderate == true
            message(:success, lang('comments.success.moderate'))
          else
            message(:success, lang('comments.success.new'))
          end
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, lang('comments.errors.new'))
        end

        redirect_referrer
      end
    end # CommentsForm
  end # Controller
end # Comments
