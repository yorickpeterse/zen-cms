module Ramaze
  module Helper
    ##
    # Helper that makes it easier to retrieve categories and category groups in
    # your templates.
    #
    # @author Yorick Peterse
    # @since  0.3
    #
    module CategoryFrontend
      ##
      # Gets a number of categories and optionally paginates them. Keep in mind
      # that this method will either return a dataset or an instance of
      # ``Ramaze::Helper::Paginate::Paginator``.
      #
      # When paginating the results and no custom ``:var`` or ``:limit`` options
      # are given this method will use the ones defined in
      # ``Zen::Controller::FrontendController.ancestral_trait[:paginate]``.
      #
      # @example Looping over a set of categories
      #  get_categories('Test Group').each do |category|
      #    puts category.name
      #  end
      #
      # @example Paginating categories
      #  categories = get_categories('Test Group', :paginate => true)
      #
      #  unless categories.empty?
      #    categories.each do |category|
      #      puts category.name
      #    end
      #  end
      #
      #  # Returns the navigation menu for the paginat5ed results.
      #  categories.navigation
      #
      # @author Yorick Peterse
      # @since  0.3
      # @param  [String|Fixnum] group The ID or name of a category group for
      #  which to retrieve all categories.
      # @param  [Hash] options A hash containing various options to customize
      #  the return value.
      # @option options [TrueClass|FalseClass] :paginate When set to true the
      #  results will be paginated. Keep in mind that this only works inside
      #  an action/template.
      # @option options [String] :var The name of the query string that contains
      #  the current page.
      # @option options [Fixnum] :limit The amount of rows to retrieve.
      # @return [Mixed]
      #
      def get_categories(group, options = {})
        trait   = Zen::Controller::FrontendController.ancestral_trait[:paginate]
        options = {
          :paginate => false,
          :var      => trait[:var],
          :limit    => trait[:limit]
        }.merge(options)

        query = Categories::Model::Category.select_all(:categories)
        query = query.join(
          :category_groups,
          :categories__category_group_id => :category_groups__id
        )

        if group.is_a?(String)
          query = query.filter(:category_groups__name => group)
        else
          query = query.filter(:category_groups__id => group)
        end

        # Paginate the results or return the dataset directly.
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
    end # CategoryFrontend
  end # Helper
end # Ramaze
