#:nodoc:
module Zen
  #:nodoc:
  module Controllers
    ##
    # The MainController controller is used to load the correct template files based
    # on the current URI. If no section is specified the default section will be retrieved
    # from the settings table.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class MainController < Zen::Controllers::FrontendController
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
        @uri     = []
        
        # Clean the URI of nasty input
        uri.each { |v| @uri.push(h(v)) }
        
        if !@uri[0] or @uri[0].empty?
          @uri[0] = settings[:default_section]
        end
        
        if !@uri[1] or @uri[1].empty?
          @uri[1] = 'index'
        end
        
        # A theme is always required
        if @settings[:theme].nil? or @settings[:theme].empty?
          respond(@zen_general_lang.errors[:no_theme])
        end

        theme    = ::Zen::Package[@settings[:theme]]
        group    = @uri[0]
        template = @uri[1]
        
        # Pre-create a few Liquid variables
        @flash         = {}
        @current_user  = {}
        flash.each { |k, v| @flash[k.to_s] = v }
        
        if !session[:user].nil?
          session[:user].values.each { |k, v| @current_user[k.to_s] = v }
        end
        
        # Create the group, template and partial paths
        theme_path    = theme.directory + '/templates'
        group_path    = theme_path + "/#{group}"
        template_path = theme_path + "/#{group}/#{template}.liquid"
        
        # Register our partial path
        partial_path                   = theme_path + "/partials"
        ::Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(partial_path)
        
        # Is the website down?
        if @settings[:website_enabled] == '0'
          offline_path = theme_path + "/offline.liquid"
          
          if File.exist?(offline_path)
            render_file(offline_path)
          else
            respond(@zen_general_lang.errors[:website_offline])
          end
        else
          # Check if the group exists
          if File.directory?(group_path) and File.exists?(template_path)
            render_file(template_path)
          else
            not_found = theme_path + "/404.liquid"
            
            if File.exist?(not_found)
              render_file(not_found)
            else
              respond(@zen_general_lang.errors[:no_templates], 404)
            end
          end
        end
      end
    end
  end
end
