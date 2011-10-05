##
# Package for managing and registering settings.
#
# ## Controllers
#
# * {Settings::Controller::Settings}
#
# ## Models
#
# * {Settings::Model::Setting}
#
# ## Plugins
#
# * {Settings::Plugin::Settings}
#
module Settings
  #:nodoc:
  module Controller
    ##
    # Controller for managing settings. Settings are used to store the name of
    # the website, what anti-spam system to use and so on. These settings can be
    # managed via the admin interface rather than having to edit configuration
    # files.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/settings
    # @event  edit_setting
    #
    class Settings < Zen::Controller::AdminController
      map   '/admin/settings'
      title 'settings.titles.%s'

      csrf_protection  :save
      load_asset_group :tabs

      ##
      # Show all settings and allow the user to change them.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_setting
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
      # Updates all the settings in both the database and the cache
      # (Ramaze::Cache.settings).
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission edit_setting
      # @event      edit_setting
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
