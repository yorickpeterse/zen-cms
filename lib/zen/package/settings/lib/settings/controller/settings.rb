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
    # files. Settings can be managed by going to ``/admin/settings``. This page
    # shows an overview of all the available settings organized in a number of
    # groups where each group is placed under it's own tab. An example of this
    # overview can be seen in the image below.
    #
    # ![General](../../_static/settings/overview_general.png)
    # ![Security](../../_static/settings/overview_security.png)
    #
    # Out of the box Zen ships with the following settings:
    #
    # * **Website name**: the name of the website.
    # * **Website description**: a short description of the website.
    # * **Language**: the default language to use for the admin interface.
    # * **Frontend Language**: the default language to use for the frontend of
    #   your website.
    # * **Theme**: the theme to use for the frontend.
    # * **Date format**: the default date format to use in the backend.
    # * **Default section**: the section to call when a visitor reaches your
    #   homepage.
    # * **Enable anti-spam**: whether or not comments should be verified to see
    #   if they're spam or ham.
    # * **Anti-spam system**: the anti-spam system to use. Zen by default only
    #   comes with Defensio support.
    # * **Defensio key**: the API key for the Defensio anti-spam system.
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_setting
    # * edit_setting
    #
    # ## Events
    #
    # Unlike other controllers events in this controller do not receive an
    # instance of a model. Instead they'll receive an instance of
    # {Settings::Plugin::SettingBase}. In order to update the value of a setting
    # you'll simply call ``#value=()`` and specify a new value.
    #
    # @example Trimming the value of a setting
    #  Zen::Event(:after_edit_setting) do |setting|
    #    if setting.name === 'website_name'
    #      setting.value = setting.value.strip
    #    end
    #  end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/settings
    # @event  after_edit_setting
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
        @groups           = ::Settings::SettingsGroup::Registered

        # Organize the settings so that each item is a child
        # item of it's group.
        ::Settings::Setting::Registered.each do |name, setting|
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
      # @event      after_edit_setting
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
          setting = get_setting(key)

          begin
            setting.value = value
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, error)

            flash[:form_errors] = setting.errors
            redirect_referrer
          end

          Zen::Event.call(:after_edit_setting, setting)
        end

        message(:success, success)
        redirect_referrer
      end
    end # Settings
  end # Controller
end # Settings
