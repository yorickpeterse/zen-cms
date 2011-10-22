module Ramaze
  module Helper
    ##
    # Helper that provides the means to retrieve comments in your templates.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    module CommentFrontend
      ##
      # Retrieves a list of comments by a section entry's ID or slug and
      # optionally paginates these comments.
      #
      # When paginating the results the default values for the ``:var`` and
      # ``:limit`` options are taken from
      # ``Zen::Controller::FrontendController.ancestral_trait[:paginate]``.
      #
      # @example Looping over a set of comments
      #  get_comments(5).each do |comment|
      #    puts comment.comment_html
      #  end
      #
      # @example Paginating the comments
      #  comments = get_comments(5, :paginate => true)
      #
      #  comments.each do |comment|
      #    puts comment.user_name
      #  end
      #
      #  comments.navigation
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [String|Fixnum] entry Either the slug of an entry or the ID of an
      #  entry for which to retrieve all comments.
      # @param  [Hash] options A hash containing various options to customize
      #  the return value.
      # @option options [TrueClass|FalseClass] :paginate Whether or not the
      #  results should be paginated. This only works inside an action.
      # @option options [Fixnum] :limit The amount of comments to retrieve.
      # @option options [String] :var The name of the query string that contains
      #  the current page.
      # @return [Mixed]
      #
      def get_comments(entry, options = {})
        trait   = Zen::Controller::FrontendController.ancestral_trait[:paginate]
        options = {
          :paginate => false,
          :limit    => trait[:limit],
          :var      => trait[:var]
        }.merge(options)

        query = Comments::Model::Comment.select_all(:comments)
        query = query.join(
          :comment_statuses,
          :comments__comment_status_id => :comment_statuses__id
        )

        # Add the section entry to the comment so that the comments can be
        # filtered by the IDs/slugs without having to use a separate query.
        query = query.join(
          :section_entries,
          :comments__section_entry_id => :section_entries__id
        )

        if entry.is_a?(String)
          query = query.filter(:section_entries__slug => entry)
        else
          query = query.filter(:section_entries__id => entry)
        end

        # Only show comments with a status of "Open"
        query = query.filter(:comment_statuses__name => 'open')
        query = query.eager(:user, :section_entry)

        if options[:paginate] == true and respond_to?(:paginate)
          return paginate(
            query,
            :var   => options[:var],
            :limit => options[:limit]
          )
        else
          if options[:limit]
            query = query.limit(options[:limit])
          end

          return query
        end
      end
    end # CommentFrontend
  end # Helper
end # Ramaze
