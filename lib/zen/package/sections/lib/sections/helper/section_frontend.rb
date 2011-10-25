module Ramaze
  module Helper
    ##
    # Helper for retrieving section entries in your templates.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    module SectionFrontend
      ##
      # Retrieves a number of entries for a given section ID or section slug.
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
      # @author Yorick Peterse
      # @since  0.2.9
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
      # @option options [TrueClass|FalseClass] :field_values Whether or not
      #  custom fields and their values should be eager loaded. When set to
      #  false the hash ``fields`` on each entry will **not** be filled.
      # @option options [TrueClass|FalseClass] :user Whether or not the user
      #  objects should be eager loaded for all entries. Set to ``false`` by
      #  default.
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
          :user                => false
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
              name             = field_value.custom_field.slug.to_sym
              row.fields[name] = field_value.html
            end
          end
        end

        return query
      end

      ##
      # Retrieves the details of a single section entry.
      #
      # @example Get a single entry
      #  entry = get_entry('home', :comments => true)
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [String|Fixnum] entry The ID or slug of an entry to retrieve.
      # @return [Mixed]
      #
      def get_entry(entry)
        row = Sections::Model::SectionEntry.find_by_pk_or_slug(entry)

        return row if row.nil?

        row.fields ||= {}

        row.custom_field_values.each do |field_value|
          name             = field_value.custom_field.slug.to_sym
          row.fields[name] = field_value.html
        end

        return row
      end
    end # SectionFrontend
  end # Helper
end # Ramaze
