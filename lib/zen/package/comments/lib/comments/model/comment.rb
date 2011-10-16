module Comments
  #:nodoc:
  module Model
    ##
    # Model for managing and retrieving comments.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Comment < Sequel::Model
      include Zen::Model::Helper

      many_to_one :section_entry , :class => 'Sections::Model::SectionEntry'
      many_to_one :user          , :class => 'Users::Model::User'
      many_to_one :comment_status, :class => 'Comments::Model::CommentStatus'

      plugin :timestamps, :create => :created_at, :update => :updated_at

      ##
      # Searches for a number of comments based on the given search query.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Array]
      #
      def self.search(query)
        return filter(search_column(:comment, query)) \
          .eager(:user, :comment_status)
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
        statuses = {}

        ::Comments::Model::CommentStatus.all.each do |status|
          statuses[status.id] = Zen::Language.lang(
            "comments.labels.#{status.name}"
          )
        end

        return statuses
      end

      ##
      # Specify the validation rules for each comment.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence([:comment, :section_entry_id])
        validates_integer([:comment_status_id, :section_entry_id])

        if user_id.nil?
          validates_presence([:name, :email])
        end
      end

      ##
      # Hook run before saving an existing comment.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def before_save
        [:name, :website, :email, :comment].each do |field|
          got = send(field)

          if !got.nil?
            send("#{field}=", Loofah.fragment(got) \
              .scrub!(:whitewash) \
              .scrub!(:nofollow).to_s)
          end
        end

        # Get the default status of a comment
        if self.comment_status_id.nil?
          self.comment_status_id = ::Comments::Model::CommentStatus[
            :name => 'closed'
          ].id
        end

        super
      end

      ##
      # Gets the name of the author of the comment. This name is either
      # retrieved from the current comment row or from an associated user
      # object.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      # @return [String]
      #
      def name
        if user.nil?
          return super
        else
          return user.name
        end
      end

      ##
      # Gets the Email address of the author of the comment.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      # @return [String]
      #
      def email
        if user.nil?
          return super
        else
          return user.email
        end
      end

      ##
      # Gets the website of the author of the comment.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      # @return [String]
      #
      def website
        if user.nil?
          return super
        else
          return user.website
        end
      end
    end # Comment
  end # Model
end # Comments
