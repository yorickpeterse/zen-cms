module EXTENSION
  module Controller
    ##
    # Describe what your controller does, no really, do it.
    #
    # @author
    # @since
    #
    class CONTROLLER < Zen::Controllers::AdminController
      include ::EXTENSION::Models

      map('/admin/module')
      
      before_all do
        csrf_protection :save, :delete do
          respond(lang('zen_general.errors.csrf'), 401)
        end
      end
      
      ##
      # Creates a new instance of the controller, loads the language file and sets the
      # title of the current page.
      #
      # @author
      # @since
      #
      def initialize
        super
        
        Zen::Language.load('language')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("language.titles.#{method}") rescue nil
        end
      end
      
      ##
      # Describe what the index() method does...
      #
      # @author
      # @since
      #
      def index
        
      end
    end # CONTROLLER
  end # Controller
end # EXTENSION
