module Comments
  module Models
    ##
    # Model that represents a single comment. This model has the following relations:
    #
    # * section entry (many to one)
    # * user (many to one)
    #
    # The following plugins are used:
    #
    # * timestamps 
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Comment < Sequel::Model
      include ::Zen::Language

      many_to_one :section_entry, :class => "Sections::Models::SectionEntry"
      many_to_one :user,          :class => "Users::Models::User"
      
      plugin :timestamps, :create => :created_at, :update => :updated_at
      
      ##
      # Specify the validation rules for each comment.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence :comment
        validates_presence :email
      end

      ##
      # Returns a hash containing all available statuses for each comment.
      #
      # @example
      #  Comments::Models::Comment.status_hash
      #
      # @author Yorick Peterse
      # @since  0.2
      # @return [Hash]
      #
      def self.status_hash
        ::Zen::Language.load('comments')

        return {
          'open'   => lang('comments.labels.open'),
          'closed' => lang('comments.labels.closed'),
          'spam'   => lang('comments.labels.spam') 
        }
      end
    end
  end
end
