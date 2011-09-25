require __DIR__('group_base')
require __DIR__('setting_base')

#:nodoc:
module Settings
  #:nodoc:
  class Plugin
    ##
    # The settings plugin is a plugin that can be used to register and migrate
    # settings without having to manually insert the data. Previously you'd have
    # to manually insert the data into the settings table at some point and the
    # process of loading translation keys and possible values was a pain. This
    # this plugin was created to solve most of those problems.
    #
    # ## Adding Settings
    #
    # In order to add a setting you'll first need to ensure there's at least a
    # single setting group available. These groups don't add any extra features
    # or whatsoever but are used to display settings in different tabs in the
    # backend interface. In order to register a new group you'd write the
    # following code:
    #
    #     plugin(:settings, :register_group) do |group|
    #       group.title = 'My Group'
    #       group.name  = 'my_group'
    #     end
    #
    # When registering a group you only need to specify a title and a name. The
    # name is used to associate a setting with it's group and thus should always
    # be unique. The title is displayed in the tab for the specific settings
    # group.
    #
    # Once a setting group has been added we can add a setting as following:
    #
    #     plugin(:settings, :register) do |setting|
    #       setting.title       = 'My Setting'
    #       setting.description = 'This is my setting!'
    #       setting.name        = 'my_setting'
    #       setting.group       = 'my_group'
    #       setting.type        = 'select'
    #       setting.values      = ['yorick', 'zen']
    #       setting.default     = 'yorick'
    #     end
    #
    # Note that the values array (or hash) is used to determine the possible
    # values for a field. These values will only be used for elements that only
    # allow a user to choose a single value (e.g. a checkbox). For the type
    # getter/setter you can use any of the following values:
    #
    # * textbox
    # * textarea
    # * radio
    # * checkbox
    # * date
    # * select
    # * select_multiple
    #
    # ## Migrating Settings
    #
    # Once a setting has been added you still have to migrate it. Zen takes care
    # of this so usually you don't need to manually migrate your settings. If
    # you do want to migrate them however you can simple execute the following
    # code:
    #
    #     plugin(:settings, :migrate)
    #
    # ## Removing Settings
    #
    # If you ever need to remove a setting both from the database and the system
    # you can do so as following:
    #
    #     plugin(:settings, :remove, ['name1', 'name2'])
    #
    # You don't have to specify an array of names, you can also specify the name
    # of a single setting to delete.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Settings
      include ::Zen::Plugin::Helper

      ##
      # Hash containing all registered settings and setting groups.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      Registered = {
        :groups   => {},
        :settings => {}
      }

      ##
      # Creates a new instance of the plugin and saves the given arguments as
      # instance variables so they can be used by
      # Settings::Plugin::Settings.call.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Symbol/String] action The action (method) to execute.
      # @param  [Array] args Array containing all additional arguments.
      # @param  [Proc] block An optional block containing extra details.
      #  a setting.
      #
      def initialize(action, *args, &block)
        # Validate the given action
        if !respond_to?(action)
          raise(ArgumentError, "The action #{action} does not exist.")
        end

        validate_type(action, :action, [Symbol, String])

        @action, @args, @block = action, args, block
      end

      ##
      # Executes the action set in the construct and returns the results.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Mixed]
      #
      def call
        return send(@action, *@args, &@block)
      end

      ##
      # Registers a new setting group using the specified block.
      #
      # @example
      #  plugin(:settings, :register_group) do |group|
      #    group.name  = 'example'
      #    group.title = 'Example group'
      #  end
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def register_group
        group = GroupBase.new

        yield group

        # Validate the group
        group.validate

        # Store the group
        Registered[:groups][group.name] = group
      end

      ##
      # Registers a new setting using the specified block.
      #
      # @example
      #  plugin(:settings, :register) do |setting|
      #    setting.name    = 'example'
      #    setting.title   = 'Example setting'
      #    setting.group   = 'example'
      #    setting.type    = 'select'
      #    setting.value   = ['yorick', 'chuck']
      #  end
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def register
        setting = SettingBase.new

        yield setting

        # Validate all attributes
        setting.validate

        Registered[:settings][setting.name] = setting
      end

      ##
      # Gets the setting for the given name.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] name The name of the setting to retrieve.
      # @return [Settings::Plugin::SettingBase]
      #
      def get(name)
        validate_type(name, :name, [String, Symbol])

        name = name.to_s

        if !Registered[:settings].key?(name)
          raise(ArgumentError, "The setting #{name} doesn't exist.")
        end

        return Registered[:settings][name]
      end

      ##
      # Inserts all settings into the database. This method will ignore the
      # settings that have already been inserted into the database.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def migrate
        settings = ::Settings::Model::Setting.all.map { |s| s.name }

        Registered[:settings].each do |name, setting|
          name = name.to_s

          if !settings.include?(name)
            # For some reason using the Settings model generates nil errors
            # when this method is called from a migration so we'll insert them
            # the non-model way.
            Zen.database[:settings].insert(
              :name    => setting.name,
              :group   => setting.group,
              :default => setting.default,
              :type    => setting.type
            )

          # Update everything but the value
          else
            Zen.database[:settings].filter[:name => setting.name].update(
              :group   => setting.group,
              :default => setting.default,
              :type    => setting.type
            )
          end
        end
      end

      ##
      # Removes the settings who's names match those specified in the array. The
      # values of these settings will also be removed from the database.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Array] namese An array with setting names to remove.
      #
      def remove(names)
        if names.class != Array
          names = [names]
        end

        names.each do |i|
          Registered[:settings].delete(i)
        end

        ::Settings::Model::Setting.filter(:name => names).delete
      end
    end # Settings
  end # Plugin
end # Settings
