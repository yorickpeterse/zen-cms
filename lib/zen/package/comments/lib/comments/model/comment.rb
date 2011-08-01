#:nodoc:
module Comments
  #:nodoc:
  module Model
    ##
    # Model that represents a single comment. This model has the following
    # relations:
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

      many_to_one :section_entry,   :class => "Sections::Model::SectionEntry"
      many_to_one :user,            :class => "Users::Model::User"
      many_to_one  :comment_status, :class => 'Comments::Model::CommentStatus'

      plugin :timestamps, :create => :created_at, :update => :updated_at

      ##
      # Specify the validation rules for each comment.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence [:comment, :section_entry_id]
        validates_integer  [:comment_status_id, :section_entry_id]

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

        statuses = {}

        ::Comments::Model::CommentStatus.all.each do |status|
          statuses[status.id] = lang("comments.labels.#{status.name}")
        end

        return statuses
      end

      ##
      # Hook run before creating a new comment.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def before_create
        prepare_comment
        super
      end

      ##
      # Hook run before saving an existing comment.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def before_save
        prepare_comment
        super
      end

      ##
      # Cleans all the input data of nasty stuff and ensures certain fields have
      # the correct values.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def prepare_comment
        [:name, :website, :email, :comment].each do |field|
          got = send(field)

          if !got.nil?
            send("#{field}=", Loofah.fragment(got).scrub!(:whitewash) \
              .scrub!(:nofollow).to_s)
          end
        end

        # Get the default status of a comment
        if self.comment_status_id.nil?
          self.comment_status_id = ::Comments::Model::CommentStatus[
            :name => 'closed'
          ].id
        end
      end
    end # Comment
  end # Model
end # Comments
