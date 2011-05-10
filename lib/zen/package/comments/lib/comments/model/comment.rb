#:nodoc:
module Comments
  #:nodoc:
  module Model
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

      many_to_one :section_entry, :class => "Sections::Model::SectionEntry"
      many_to_one :user,          :class => "Users::Model::User"
      
      plugin :timestamps, :create => :created_at, :update => :updated_at
      
      ##
      # Specify the validation rules for each comment.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence :comment

        if user_id.nil?
          validates_presence :email
        end
      end

      ##
      # Returns a hash containing all available statuses for each comment.
      #
      # @example
      #  Comments::Model::Comment.status_hash
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

      ##
      # Hook run before creating a new comment.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def before_create
        super
        sanitize
      end

      ##
      # Hook run before saving an existing comment.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def before_save
        super
        sanitize
      end

      ##
      # Cleans all the input data of nasty stuff.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def sanitize
        [:name, :website, :email, :comment].each do |field|
          got = send(field)

          if !got.nil?
            send("#{field}=", Loofah.fragment(got).scrub!(:whitewash).scrub!(:nofollow).to_s)
          end
        end
      end
    end # Comment
  end # Model
end # Comments
