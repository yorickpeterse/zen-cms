#:nodoc:
module Settings
  #:nodoc:
  module Controller
    ##
    # Controller for managing settings. Each setting is saved as a separate
    # row in the database, making management and retrieving them easier.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Settings < Zen::Controller::AdminController
      map '/admin/settings'

      load_asset_group(:tabs)

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
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

        @form_save_url = Settings.r(:save)
        @page_title    = lang("settings.titles.#{action.method}") rescue nil
      end

      ##
      # Show all settings and allow the user to change them.
      # The values of each setting item are stored in the database,
      # the descriptions, names and possible values are stored in
      # the language packs that come with this module.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        require_permissions(:show_setting)

        set_breadcrumbs(lang('settings.titles.index'))

        @settings_ordered = {}
        @groups           = ::Settings::Plugin::Settings::Registered[:groups]

        # Organize the settings so that each item is a child
        # item of it's group.
        ::Settings::Plugin::Settings::Registered[:settings].each \
        do |name, setting|
          if !@settings_ordered.key?(setting.group)
            @settings_ordered[setting.group] = []
          end

          @settings_ordered[setting.group].push(setting)
        end
      end

      ##
      # Saves the values of each setting. Since each setting
      # is a new row we'll have to loop through them and execute quite
      # a few queries.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        require_permissions(:edit_setting)

        post = request.params.dup
        post.delete('csrf_token')
        post.delete('id')

        flash_success = lang('settings.success.save')
        flash_error   = lang('settings.errors.save')

        # Update all settings
        post.each do |key, value|
          begin
            plugin(:settings, :get, key).value = value
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, flash_error)

            flash[:form_errors] = setting.errors
            redirect_referrer
          end
        end

        message(:success, flash_success)
        redirect_referrer
      end
    end # Settings
  end # Controller
end # Settings
