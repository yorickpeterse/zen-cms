module EXTENSION
  module Controllers
    ##
    #
    # @author
    # @since
    #
    class CONTROLLER < Zen::Controllers::AdminController
      map_extension "/admin/module"
      
      include ::EXTENSION::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 401)
        end
      end
      
      ##
      #
      # @author
      # @since
      #
      def initialize
        super
        
        @form_save_url = ''
        @lang = Zen::Language.load ''
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @lang.titles.key? method 
            @page_title = @lang.titles[method]
          end
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
