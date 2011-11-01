module Comments
  #:nodoc:
  module Model
    ##
    # Model for managing and retrieving comments.
    #
    # @since  0.1
    #
    class Comment < Sequel::Model
      include Zen::Model::Helper

      many_to_one :section_entry, :class => 'Sections::Model::SectionEntry',
        :eager => [:section]

      many_to_one :user          , :class => 'Users::Model::User'
      many_to_one :comment_status, :class => 'Comments::Model::CommentStatus'

      plugin :timestamps, :create => :created_at, :update => :updated_at

      ##
      # Searches for a number of comments based on the given search query. The
      # following fields can be searched:
      #
      # * comments.comment
      # * comments.email
      # * comments.name
      # * users.email
      # * users.name
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Array]
      #
      def self.search(query)
        return select_all(:comments) \
          .filter(
            search_column(:comment, query) |
            search_column(:users__email, query) |
            search_column(:comments__email, query) |
            search_column(:comments__name, query) |
            search_column(:users__name, query)
          ) \
          .eager(:user, :comment_status) \
          .left_join(:users, :comments__user_id => :users__id)
      end

      ##
      # Returns a hash containing all available statuses for each comment.
      #
      # @example
      #  Comments::Model::Comment.status_hash
      #
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
      # @since  0.1
      #
      def validate
        validates_presence([:comment, :section_entry_id])
        validates_integer([:comment_status_id, :section_entry_id])
        validates_max_length(255, [:name, :email, :website])

        if user_id.nil?
          validates_presence([:name, :email])
        end
      end

      ##
      # Hook run before saving an existing comment.
      #
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
      # @since  16-10-2011
      # @return [String]
      #
      def user_name
        if user.nil?
          return name
        else
          return user.name
        end
      end

      ##
      # Gets the Email address of the author of the comment.
      #
      # @since  16-10-2011
      # @return [String]
      #
      def user_email
        if user.nil?
          return email
        else
          return user.email
        end
      end

      ##
      # Gets the website of the author of the comment and optionally creates an
      # anchor tag for it.
      #
      # @since  16-10-2011
      # @param  [TrueClass|FalseClass] with_link When set to true the website
      #  will be returned as an ``<a>`` tag.
      # @return [String]
      #
      def user_website(with_link = false)
        if user.nil?
          website = website
        else
          website = user.website
        end

        if !website.nil? and !website.empty? and with_link == true
          website = '<a href="%s" title="%s">%s</a>' % [
            website,
            website,
            website
          ]
        end

        return website
      end

      ##
      # Returns the first 15 characters of a comment, optionally wrapped in a
      # link that points to the form to edit the comment.
      #
      # @since  17-10-2011
      # @param  [TrueClass|FalseClass] with_link When set to true the comment
      #  will be wrapped in an ``<a>`` tag.
      # @return [String]
      #
      def summary(with_link = false)
        _comment = comment || ''
        _comment = _comment[0, 15] + '...'

        if with_link == true
          return ::Comments::Controller::Comments.a(_comment, :edit, id)
        else
          return _comment
        end
      end

      ##
      # Returns the text of the comment in HTML based on the markup engine used
      # by the section that the comment belongs to.
      #
      # @since  0.3
      # @return [String]
      #
      def html
        return Zen::Markup.convert(
          section_entry.section.comment_format,
          comment
        )
      end

      ##
      # Returns the name of the comment status.
      #
      # @since  17-10-2011
      # @return [String]
      #
      def status_name
        return lang("comments.labels.#{comment_status.name}")
      end
    end # Comment
  end # Model
end # Comments
