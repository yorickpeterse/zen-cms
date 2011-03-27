module EXTENSION
  module Controllers
    ##
    #
    # @author
    # @since
    #
    class CONTROLLER < Zen::Controllers::AdminController
      include ::EXTENSION::Models

      map   "/admin/module"
      trait :extension_identifier => ''
      
      before_all do
        csrf_protection :save, :delete do
          respond(lang('zen_general.errors.csrf'), 401)
        end
      end
      
      ##
      #
      # @author
      # @since
      #
      def initialize
        super
        
        Zen::Language.load 'language'
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("language.titles.#{method}") rescue nil
        end
      end
      
      ##
      #
      # @author
      # @since
      #
      def index
        
      end
      
      ##
      #
      # @author
      # @since
      #
      def edit
        
      end
      
      ##
      #
      # @author
      # @since
      #
      def new
        
      end
      
      ##
      #
      # @author
      # @since
      #      
      def save
        
      end

      ##
      #
      # @author
      # @since
      #      
      def delete
        
      end
    end
  end
end
