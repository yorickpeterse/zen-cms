module Comments
  #:nodoc:
  module Controller
    ##
    # Controller that makes it possible for users to submit comments to section
    # entries. Zen does not provide any way of generating a comment form for
    # you and thus you'll have to do this yourself. When creating such a form
    # you must add the following fields to it:
    #
    # <table class="table full">
    #     <thead>
    #         <tr>
    #             <th>Field</th>
    #             <th>Required</th>
    #             <th>Maximum Length</th>
    #             <th>Description</th>
    #         </tr>
    #     </thead>
    #     <tbody>
    #         <tr>
    #             <td>section_entry</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The ID of the section entry the comment belongs to.</td>
    #         </tr>
    #         <tr>
    #             <td>user_id</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>A short description of the category group.</td>
    #         </tr>
    #         <tr>
    #             <td>comment</td>
    #             <td>Yes</td>
    #             <td>Unlimited</td>
    #             <td>The text of the comment.</td>
    #         </tr>
    #         <tr>
    #             <td>name</td>
    #             <td>Only when the user isn't logged in.</td>
    #             <td>255</td>
    #             <td>The name of the comment author.</td>
    #         </tr>
    #         <tr>
    #             <td>website</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>The website of the comment author.</td>
    #         </tr>
    #         <tr>
    #             <td>email</td>
    #             <td>Only when the user isn't logged in.</td>
    #             <td>255</td>
    #             <td>The Email address of the user.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # An example of such a form looks like the code below. Note that this block
    # of code should be wrapped in a ``#{}`` tag.
    #
    #     form_for(
    #       flash[:form_data],
    #       :method => :post,
    #       :action => Comments::Controller::CommentsForm.r(:save)
    #     ) do |f|
    #       if logged_in?
    #         f.input_hidden(:user_id, user.id)
    #       end
    #
    #       f.input_hidden(:section_entry, 10)
    #
    #       # No need to show these, they'll be filled in based on the user ID.
    #       unless logged_in?
    #         f.input_text('Name', :name)
    #         f.input_text('Email', :email)
    #         f.input_text('Website', :website)
    #       end
    #
    #       f.textarea('Comment', :comment)
    #
    #       f.input_submit('Submit')
    #     end
    #
    # In the above example ``flash[:form_data]`` is used. This controller sets
    # two objects in the flash just like the backend controllers. These are the
    # following two items:
    #
    # * **form_data**: an instance of {Comments::Model::Comment}
    # * **form_errros**: a hash containing all errors, automatically used by
    # ``Ramaze::Helper::BlueForm`` if the form was created using the
    # ``form_for()`` method.
    #
    # Note that both these objects are only set if the comment contained invalid
    # data or the user wasn't allowed to submit the comment.
    #
    # In the above example the BlueForm helper was used but you're free to use
    # plain old HTML or another helper if you like. If you want to use a helper
    # you'll have to load it into {Zen::Controller::MainController}. This can
    # be done as following:
    #
    #     Zen::Controller::MainController.helper(:some_helper_name)
    #
    # @since 0.1
    # @map   /comments-form
    #
    class CommentsForm < Zen::Controller::FrontendController
      map    '/comments-form'
      helper :message

      csrf_protection :save

      ##
      # Creates a new comment for the section entry. Once the comment has been
      # saved the user will be redirected back to the previous page.
      #
      # @since  0.1
      #
      def save
        comment = ::Comments::Model::Comment.new
        post    = post_fields(
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
        if entry.nil? or entry.section_entry_status_id == draft_status
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
        if section.comment_allow == false
          message(:error, lang('comments.errors.comments_not_allowed'))
          redirect_referrer
        end

        # Comments require an account?
        if section.comment_require_account == true and !logged_in?
          message(:error, lang('comments.errors.comments_require_account'))
          redirect_referrer
        end

        # Require moderation?
        if section.comment_moderate == true
          comment.comment_status_id = comment_statuses['closed']
        end

        # Get the details for the anti spam plugin
        if !post['user_id'].nil? and !post['user_id'].empty?
          user  = ::Users::Model::User[post['user_id']]
          name  = user.name
          email = user.email
          url   = user.website
        else
          name  = post['name']
          email = post['email']
          url   = post['website']
        end

        # Require anti-spam validation?
        if get_setting(:enable_antispam).true?
          engine = get_setting(:anti_spam_system).value
          spam   = ::Comments::AntiSpam.validate(
            engine,
            name,
            email,
            url,
            post['comment']
          )

          # Is it spam?
          if spam == false
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
        rescue => e
          Ramaze::Log.error(e)
          message(:error, lang('comments.errors.new'))

          flash[:form_data]   = comment
          flash[:form_errors] = comment.errors

          redirect_referrer
        end

        if section.comment_moderate == true
          message(:success, lang('comments.success.moderate'))
        else
          message(:success, lang('comments.success.new'))
        end

        redirect_referrer
      end
    end # CommentsForm
  end # Controller
end # Comments
