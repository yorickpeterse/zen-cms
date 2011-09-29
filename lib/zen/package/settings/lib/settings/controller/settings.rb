#:nodoc:
module Settings
  #:nodoc:
  module Controller
    ##
    # Controller for managing settings. Each setting is saved as a separate
    # row in the database, making management and retrieving them easier.
    #
    # ## Used Permissions
    #
    # * show_setting
    # * edit_setting
    #
    # ## Available Events
    #
    # * edit_setting
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Settings < Zen::Controller::AdminController
      map   '/admin/settings'
      title 'settings.titles.%s'

      csrf_protection  :save
      load_asset_group :tabs

      ##
      # Show all settings and allow the user to change them. The values of each
      # setting item are stored in the database, the descriptions, names and
      # possible values are stored in the language packs that come with this
      # module.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_setting)

        set_breadcrumbs(lang('settings.titles.index'))

        @settings_ordered = {}
        @groups           = ::Settings::Plugin::Settings::Registered[:groups]

        # Organize the settings so that each item is a child
        # item of it's group.
        ::Settings::Plugin::Settings::Registered[:settings] \
        .each do |name, setting|
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
        authorize_user!(:edit_setting)

        post = request.params
        post.delete('csrf_token')
        post.delete('id')

        success = lang('settings.success.save')
        error   = lang('settings.errors.save')

        # Update all settings
        post.each do |key, value|
          setting = plugin(:settings, :get, key)

          begin
            setting.value = value
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, error)

            flash[:form_errors] = setting.errors
            redirect_referrer
          end

          Zen::Event.call(:edit_setting, setting)
        end

        message(:success, success)
        redirect_referrer
      end
    end # Settings
  end # Controller
end # Settings
