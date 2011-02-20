module Settings
  module Controllers
    ##
    # Controller for managing settings. Each setting is saved as a separate
    # row in the database, making management and retrieving them easier.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Settings < Zen::Controllers::AdminController
      include ::Settings::Models

      map   "/admin/settings"
      trait :extension_identifier => 'com.zen.settings'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(@zen_general_lang.errors[:csrf], 403)
        end
      end
      
      ##
      # Load our language packs, set the form URLs and define our page title.
      #
      # This method loads the following language files:
      #
      # * settings
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = Settings.r(:save)
        @settings_lang   = Zen::Language.load('settings')
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @settings_lang.titles.key? method 
            @page_title = @settings_lang.titles[method]
          end
        end
      end
      
      ##
      # Show all settings and allow the user to change them.
      # The values of each setting item are stored in the database,
      # the descriptions, names and possible values are stored in
      # the language packs that come with this module.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @settings_lang.titles[:index]
        
        settings  = Setting.all
        @settings = {}
        
        # Organize the settings so that each item is a child
        # item of it's group.
        settings.each do |s|
          if !@settings.key?(s.group_key)
            @settings[s.group_key.to_s] = []
          end
          
          @settings[s.group_key.to_s].push(s)
        end
      end
      
      ##
      # Saves the values of each setting. Since each setting
      # is a new row we'll have to loop through them and execute quite
      # a few queries.
      #
      # This method requires the following permissions:
      #
      # * update
      # 
      # @author Yorick Peterse
      # @since  0.1
      #      
      def save
        if !user_authorized?([:update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
        post.delete('csrf_token')

        flash_success = @settings_lang.success[:save]
        flash_error   = @settings_lang.errors[:save]
        
        begin
          post.each do |key, value|
            @setting = Setting[:key => key].update(:value => value)  
          end
          
          notification(:success, @settings_lang.titles[:index], flash_success)
        rescue
          notification(:error, @settings_lang.titles[:index], flash_error)
          
          flash[:form_errors] = @setting.errors
        end
        
        redirect_referrer
      end
    end
  end
end
