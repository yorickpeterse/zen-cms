#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The MainController controller is used to load the correct template files
    # based on the current URI. If no section is specified the default section
    # will be retrieved from the settings table.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class MainController < Zen::Controller::FrontendController
      map '/'

      ##
      # The index method acts as a catch-all method. Based on the requested URI
      # the correct template group/file will be loaded. If no templates are
      # found a 404 template will be loaded. If that's not found either a
      # default error will be shown.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Array] uri Array containing all arguments (thus the URI).
      #
      def index(*uri)
        @request_uri = []
        theme        = plugin(:settings, :get, :theme).value

        # Clean the URI of nasty input
        uri.each { |v| @request_uri.push(h(v)) }

        if !@request_uri[0] or @request_uri[0].empty?
          section         = plugin(:settings, :get, :default_section).value
          section         = ::Sections::Model::Section[section].slug
          @request_uri[0] = section
        end

        if !@request_uri[1] or @request_uri[1].empty?
          @request_uri[1] = 'index'
        end

        # A theme is always required
        if theme.nil? or theme.empty?
          respond(lang('zen_general.errors.no_theme'))
        end

        theme    = ::Zen::Theme[theme]
        group    = @request_uri[0]
        template = @request_uri[1]

        # Create the group, template and partial paths
        theme_path    = theme.template_dir
        group_path    = File.join(theme_path, group)
        template_path = File.join(theme_path, group, "#{template}.xhtml")

        # Check if the group exists
        if File.directory?(group_path) and File.exists?(template_path)
          render_file(template_path)
        else
          not_found = File.join(theme_path, '404.xhtml')

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
