module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper used by the comments package.
    #
    # @since  0.2.8
    #
    module Comment
      ##
      # Given a comment ID this method checks if that ID results in a valid
      # instance of Comments::Model::Comment. If this is the case the object is
      # returned, otherwise the user is redirected back to the comment overview
      # and is shown a message.
      #
      # @since  0.2.8
      # @param  [Fixnum] comment_id The ID of the comment to validate.
      # @return [Comments::Model::Comment]
      #
      def validate_comment(comment_id)
        comment = ::Comments::Model::Comment[comment_id]

        if comment.nil?
          message(:error, lang('comments.errors.invalid_comment'))
          redirect(::Comments::Controller::Comments.r(:index))
        else
          return comment
        end
      end
    end # Comment
  end # Helper
end # Ramaze
