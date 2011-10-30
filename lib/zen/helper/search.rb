module Ramaze
  module Helper
    ##
    # The Search helper is a helper that can be used in controllers allowing the
    # user to search the content of those controllers and models.
    #
    # @since  16-10-2011
    #
    module Search
      ##
      # Renders a search form that points to the given URL.
      #
      # @since  16-10-2011
      # @param  [#to_s] url The URL to point the search form to.
      # @return [String]
      #
      def render_search_form(url)
        render_file(
          __DIR__('../view/search.xhtml'),
          :url => url.to_s
        )
      end

      ##
      # Calls the given block used to search a number of records. If the search
      # action raises an error a message is displayed and the user will be
      # redirected back to the previous page.
      #
      # If no search query is specified nil will be returned.
      #
      # @example
      #  results = search do |query|
      #    Sections::Model::Section.search(query)
      #  end
      #
      # @since  16-10-2011
      # @return [NilClass|Mixed]
      #
      def search
        if request.params['query'].nil? or request.params['query'].empty?
          return nil
        end

        begin
          return yield(request.params['query'])
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, lang('zen_general.errors.invalid_search'))
          redirect_referrer(::Sections::Controller::Sections.r(:index))
        end
      end
    end # Search
  end # Helper
end # Ramaze
