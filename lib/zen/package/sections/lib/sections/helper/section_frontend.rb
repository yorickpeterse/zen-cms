module Ramaze
  module Helper
    ##
    # Helper for retrieving section entries in your templates. See
    # {Ramaze::Helper::SectionFrontend#get\_entries} and
    # {Ramaze::Helper::SectionFrontend#get\_entry}.
    #
    # @since  0.3
    #
    module SectionFrontend
      ##
      # Retrieves a number of entries for a given section ID or section slug.
      # The return value is a Sequel dataset or an empty array in case no rows
      # were found.
      #
      # Each row returned by this method is an instance of
      # {Sections::Model::SectionEntry}. The custom fields and their values of
      # each row are stored as a hash (the keys are symbols) in the "fields"
      # attribute. For example, if you want to access the value of the "body"
      # custom field you can do so as following:
      #
      #     get_entries('pages').each do |page|
      #       puts page.fields[:body]
      #     end
      #
      # Because the returned value is a Sequel dataset paginating content is
      # very easy. This can be done by setting the option `:paginate` to true
      # and calling `#navigation()` on the result set to generate a list of
      # pagination links:
      #
      #     pages = get_entries('pages', :paginate => true)
      #
      #     pages.each do |page|
      #       # ...
      #     end
      #
      #     pages.navigation
      #
      # ## Lazy Loading
      #
      # To increase performance this method does not automatically retrieve
      # related data such as comments and categories until they are used.
      # However, if you plan on using this data for each returned row it is
      # recommended to eager load this data as you'll otherwise have to execute
      # a number of extra queries for each row.
      #
      # For example, this code block would generate a query for every row in
      # order to retrieve user data:
      #
      #     get_entries('pages').each do |page|
      #       page.user.email
      #     end
      #
      # To work around this problem you can set the option `:user` (or another
      # option depending on the related data you plan on using) to `true`. Doing
      # so will make it possible to retrieve all related rows in a single query:
      #
      #     get_entries('pages', :user => true).each do |page|
      #       page.user.email
      #     end
      #
      # The following options can be set to `true` to enable eager loading
      # (these are set to `false` by default):
      #
      # * comments
      # * categories
      # * user
      #
      # ## Disabling Markup
      #
      # By default each row's markup will be converted to HTML. If you don't
      # need the markup you can disable this to speed things up a bit. This can
      # be done by setting `:markup` to `false`:
      #
      #     get_entries('pages', :markup => false).each do |page|
      #       page.title
      #     end
      #
      # ## Etanni Example
      #
      # Below is an example on how to use this method inside an Etanni template.
      #
      #     <?r entries = get_entries('blog', :user => true) ?>
      #
      #     <?r entries.each do |entry| ?>
      #     <article>
      #         <header>
      #             <h1>#{entry.title}</h1>
      #             <p>Written by #{entry.user.name}</p>
      #         </header>
      #
      #         <div class="body">
      #             #{entry.fields[:body]}
      #         </div>
      #     </article>
      #     <?r end ?>
      #
      #     #{entries.navigation}
      #
      # @example Retrieving all entries by a section's ID
      #  get_entries(2)
      #
      # @example Retrieving all entries by a section's slug
      #  get_entries('pages')
      #
      # @example Paginating the results
      #  entries = get_entries('pages', :paginate => true)
      #
      #  entries.each do |entry|
      #    puts entry.title
      #  end
      #
      #  entries.navigation
      #
      # @example Customizing the sort order
      #  get_entries('pages', :order_by => :created_at, :order => :asc)
      #
      # @since  0.3
      # @param  [String|Fixnum] section The ID or slug of an section for which
      #  to retrieve a number of entries.
      # @param  [Hash] options A hash containing various options to customize
      #  the return value.
      # @option options [Fixnum] :limit The maximum amount of entries to
      #  retrieve.
      # @option options [TrueClass|FalseClass] :comments Whether or not all
      #  comments should be eager loaded, set to ``false`` by default.
      # @option options [TrueClass|FalseClass] :categories Whether or not all
      #  categories have to be eager loaded, set to ``false`` by default.
      # @option options [Symbol] :order_by The column to order the results on.
      # @option options [Symbol] :order The sort order to use, set to ``:desc``
      #  by default.
      # @option options [TrueClass|FalseClass] :paginate Whether or not the
      #  results should be paginated.
      # @option options [String] :var The name of the query string item that
      #  contains the current page number.
      # @option options [TrueClass|FalseClass] :custom_field_values Whether or
      #  not custom fields and their values should be eager loaded. When set to
      #  false the hash ``fields`` on each entry will **not** be filled.
      # @option options [TrueClass|FalseClass] :user Whether or not the user
      #  objects should be eager loaded for all entries. Set to ``false`` by
      #  default.
      # @option options [TrueClass|FalseClass] :markup When set to true
      #  (default) the values of custom fields are processed using
      #  {Zen::Markup}.
      # @return [Mixed]
      #
      def get_entries(section, options = {})
        trait   = Zen::Controller::FrontendController.ancestral_trait[:paginate]
        options = {
          :limit               => trait[:limit],
          :var                 => trait[:var],
          :paginate            => false,
          :comments            => false,
          :categories          => false,
          :order_by            => :id,
          :order               => :desc,
          :custom_field_values => true,
          :user                => false,
          :markup              => true
        }.merge(options)

        eager = [:section]

        # Determine what relations to eager load.
        [:custom_field_values, :user, :comments, :categories].each do |k|
          if options[k] == true
            eager << k
          end
        end

        # Build the query
        query = Sections::Model::SectionEntry.select_all(:section_entries) \
          .eager(*eager) \
          .join(:sections, :section_entries__section_id => :sections__id)

        if section.is_a?(String)
          query = query.filter(:sections__slug => section)
        else
          query = query.filter(:sections__id => section)
        end

        query = query.order(options[:order_by].send(options[:order]))

        # Paginate the results?
        if options[:paginate] == true
          query = paginate(
            query,
            :var   => options[:var],
            :limit => options[:limit]
          )
        else
          query = query.limit(options[:limit]).all
        end

        # Loop over the rows and create a hash containing the custom fields and
        # values of each entry.
        query.each do |row|
          row.fields ||= {}

          # Get the fields?
          if options[:custom_field_values] == true
            row.custom_field_values.each do |field_value|
              name = field_value.custom_field.slug.to_sym

              if options[:markup] == true
                row.fields[name] = field_value.html
              else
                row.fields[name] = field_value.value
              end
            end
          end
        end

        return query
      end

      ##
      # Retrieves the details of a single section entry. Due to the nature of
      # this method all related data such as user details and categories are
      # lazy loaded.
      #
      # @example Get a single entry by the entry slug.
      #  entry = get_entry('home')
      #
      #  puts entry.title
      #
      # @example Get an entry by its ID.
      #  entry = get_entry(10)
      #
      #  puts entry.title
      #
      # @since  0.3
      # @see    Ramaze::Helper::SectionFrontend#get_entries()
      # @param  [String|Fixnum] entry The ID or slug of an entry to retrieve.
      # @param  [Hash] options A hash containing various options to customize
      #  the return value.
      # @option options [TrueClass|FalseClass] :markup When set to true
      #  (default) the values of custom fields are processed using
      #  {Zen::Markup}}.
      # @return [Mixed]
      #
      def get_entry(entry, options = {})
        options = {:markup => true}.merge(options)
        row     = Sections::Model::SectionEntry.find_by_pk_or_slug(entry)

        return row if row.nil?

        row.fields ||= {}

        row.custom_field_values.each do |field_value|
          name = field_value.custom_field.slug.to_sym

          if options[:markup] == true
            row.fields[name] = field_value.html
          else
            row.fields[name] = field_value.value
          end
        end

        return row
      end
    end # SectionFrontend
  end # Helper
end # Ramaze
