#:nodoc:
module Comments
  #:nodoc:
  module Model
    ##
    # Model used for managing the statuses of a comment.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class CommentStatus < Sequel::Model
      many_to_one :comment, :class => 'Comments::Model::CommentStatus'
    end # CommentStatus
  end # Model
end # Comments
