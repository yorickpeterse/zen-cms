module Zen
  module Controller
    ##
    # The MainController controller is used to load the correct template files
    # based on the current URI.
    #
    # @since  0.1
    #
    class MainController < Zen::Controller::FrontendController
      map '/'

      ##
      # Determines what template group and template have to be rendered based on
      # the requested URI. If the template does not exist a 404 template
      # (404.xhtml) will be rendered. If that template doesn't exist either a
      # plain text message will be displayed.
      #
      # @since  0.1
      # @param  [Array] uri Array containing all the URI segments that were
      #  specified (without any file extensions).
      #
      def index(*uri)
        @request_uri = uri.map { |v| h(v) }
        theme        = get_setting(:theme).value

        if theme.nil? or theme.empty?
          respond(lang('zen_general.errors.no_theme'))
        end

        theme = Zen::Theme[theme]

        if !@request_uri[0] or @request_uri[0].empty?
          @request_uri[0] = theme.default_template_group
        end

        if !@request_uri[1] or @request_uri[1].empty?
          @request_uri[1] = 'index'
        end

        path  = File.join(
          theme.templates,
          @request_uri[0],
          "#{@request_uri[1]}.xhtml"
        )

        if File.exist?(path)
          render_file(path)
        else
          not_found = File.join(theme.templates, '404.xhtml')

          if File.exist?(not_found)
            respond(render_file(not_found), 404)
          else
            respond(lang('zen_general.errors.no_templates'), 404)
          end
        end
      end
    end # MainController
  end # Controller
end # Zen
