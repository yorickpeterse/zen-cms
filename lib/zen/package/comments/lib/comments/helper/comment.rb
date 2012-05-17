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
        redirect_invalid_comment unless comment_id =~ /\d+/

        comment = ::Comments::Model::Comment[comment_id]

        if comment.nil?
          redirect_invalid_comment
        else
          return comment
        end
      end

      ##
      # Redirects the user to the comments overview and shows a message
      # informing the user that the comment he/she tried to access was invalid.
      #
      # @since 2012-04-05
      #
      def redirect_invalid_comment
        message(:error, lang('comments.errors.invalid_comment'))
        redirect(::Comments::Controller::Comments.r(:index))
      end
    end # Comment
  end # Helper
end # Ramaze
