#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The MainController controller is used to load the correct template files based
    # on the current URI. If no section is specified the default section will be retrieved
    # from the settings table.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class MainController < Zen::Controller::FrontendController
      map '/'
      
      ##
      # The index method acts as a catch-all method. Based on the requested URI
      # the correct template group/file will be loaded. If no templates are found
      # a 404 template will be loaded. If that's not found either a default error
      # will be shown. If the website is offline we'll try to load the template
      # "offline", if it isn't there a regular message will be displayed.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Array] uri Array containing all arguments (thus the URI).
      #
      def index(*uri)
        @request_uri = []
        
        # Clean the URI of nasty input
        uri.each { |v| @request_uri.push(h(v)) }
        
        if !@request_uri[0] or @request_uri[0].empty?
          @request_uri[0] = ::Zen::Settings[:default_section]
        end
        
        if !@request_uri[1] or @request_uri[1].empty?
          @request_uri[1] = 'index'
        end
        
        # A theme is always required
        if ::Zen::Settings[:theme].nil? or ::Zen::Settings[:theme].empty?
          respond(lang('zen_general.errors.no_theme'))
        end

        theme    = ::Zen::Theme[::Zen::Settings[:theme]]
        group    = @request_uri[0]
        template = @request_uri[1]
        
        # Create the group, template and partial paths
        theme_path    = theme.template_dir
        group_path    = File.join(theme_path, group)
        template_path = File.join(theme_path, group, "#{template}.xhtml")
        
        # Is the website down?
        if ::Zen::Settings[:website_enabled] == '0'
          offline_path = File.join(theme_path, 'offline.xhtml')
          
          if File.exist?(offline_path)
            render_file(offline_path)
          else
            respond(lang('zen_general.errors.website_offline'))
          end
        else
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
      end
    end
  end
end
