module Settings
  ##
  # {Settings::Setting} is a class that can be used to register and migrate
  # settings without having to manually insert the data. It provides an API
  # similar to registering packages or themes and takes care of synchronizing
  # data between the database and the cache.
  #
  # ## Adding Settings
  #
  # In order to add a setting you'll first need to ensure there's at least a
  # single setting group available. These groups don't add any extra features
  # or whatsoever but are used to display settings in different tabs in the
  # backend interface. In order to register a new group you'd write the
  # following code:
  #
  #     Settings::SettingsGroup.add do |group|
  #       group.title = 'My Group'
  #       group.name  = :my_group
  #     end
  #
  # When registering a group you only need to specify a title and a name. The
  # name is used to associate a setting with it's group and thus should always
  # be unique. The title is displayed in the tab for the specific settings
  # group.
  #
  # Once a setting group has been added we can add a setting as following:
  #
  #     Settings::Setting.add do |setting|
  #       setting.title       = 'My Setting'
  #       setting.description = 'This is my setting!'
  #       setting.name        = :my_setting
  #       setting.group       = :my_group
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
  #     Settings::Setting.migrate
  #
  # ## Removing Settings
  #
  # If you ever need to remove a setting both from the database and the system
  # you can do so as following:
  #
  #     Settings::Setting.remove([:name, :name1])
  #
  # You don't have to specify an array of names, you can also specify the name
  # of a single setting to delete.
  #
  # @since  0.2.5
  #
  class Setting
    include ::Zen::Validation

    # Array containing all possible setting types.
    Types = [
      'textbox',
      'textarea',
      'radio',
      'checkbox',
      'date',
      'select',
      'select_multiple'
    ]

    # Hash containing all registered settings.
    REGISTERED = {}

    # The name of the setting
    attr_reader :name

    # The title of the setting, displayed in the GUI
    attr_writer :title

    # A small description about the setting
    attr_writer :description

    # The name of the settings group this setting belongs to
    attr_reader :group

    # The type of setting (e.g. textbox)
    attr_accessor :type

    # The possible values for the setting
    attr_writer :values

    # The default value of the setting
    attr_accessor :default

    class << self
      ##
      # Registers a new setting using the specified block.
      #
      # @example
      #  Settings::Setting.add do |setting|
      #    setting.name    = 'example'
      #    setting.title   = 'Example setting'
      #    setting.group   = 'example'
      #    setting.type    = 'select'
      #    setting.values  = ['yorick', 'chuck']
      #  end
      #
      # @since  0.2.5
      #
      def add
        setting = self.new

        yield setting

        setting.validate

        REGISTERED[setting.name] = setting
      end

      ##
      # Inserts all settings into the database. This method will ignore the
      # settings that have already been inserted into the database.
      #
      # @since  0.2.5
      #
      def migrate
        settings = ::Settings::Model::Setting.all.map { |s| s.name }

        REGISTERED.each do |name, setting|
          name = name.to_s

          if !settings.include?(name)
            Zen.database[:settings].insert(
              :name  => name,
              :value => setting.serialize(setting.default)
            )
          end
        end
      end

      ##
      # Removes the settings who's names match those specified in the array. The
      # values of these settings will also be removed from the database.
      #
      # @since  0.2.5
      # @param  [Array] namese An array with setting names to remove.
      #
      def remove(names)
        if names.class != Array
          names = [names]
        end

        names.each_with_index do |v, k|
          names[k] = v.to_s
          REGISTERED.delete(v.to_sym)
        end

        ::Settings::Model::Setting.filter(:name => names).destroy
      end
    end # class << self

    ##
    # Validates all attributes of this class.
    #
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :title, :group, :type])

      # Validate the setting type
      if !Types.include?(type)
        raise(::Zen::ValidationError, "The setting type \"#{type}\" is invalid.")
      end

      # Check if the setting hasn't been registered yet
      if REGISTERED.key?(name)
        raise(
          ::Zen::ValidationError,
          "The setting #{name} has already been registered"
        )
      end

      # Validate the group
      if !Settings::SettingsGroup::REGISTERED.key?(group)
        raise(
          ::Zen::ValidationError,
          "The settings group \"#{group}\" doesn't exist."
        )
      end
    end

    ##
    # Sets the name of the setting and converts it to a symbol.
    #
    # @since  0.3
    # @param  [#to_sym] name The name of the setting.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Sets the name of the group this setting belongs to.
    #
    # @since  0.3
    # @param  [#to_sym] group The name of the settings group.
    #
    def group=(group)
      @group = group.to_sym
    end

    ##
    # Returns the title of the setting and tries to translate it.
    #
    # @since  0.3
    # @return [String]
    #
    def title
      begin
        return lang(@title)
      rescue
        return @title
      end
    end

    ##
    # Returns the description of the setting and translates it.
    #
    # @since  13-11-2011
    # @return [String]
    #
    def description
      begin
        return lang(@description)
      rescue
        return @description
      end
    end

    ##
    # Updates the value of a setting both in the cache and the SQL database.
    #
    # @since  0.2.6.1
    # @param  [String] value The value to set the setting to.
    #
    def value=(value)
      value = serialize(Zen::Security.sanitize(value))

      # First we'll update the SQL database
      ::Settings::Model::Setting[:name => name.to_s].update(:value => value)

      # Sync the cache
      ::Ramaze::Cache.settings.store(name, value)
    end

    ##
    # Retrieves the setting. If it exists in the cache the cache's value is
    # used, otherwise it will be retrieved from the SQL database and cached.
    #
    # @since  0.2.6.1
    #
    def value
      val = ::Ramaze::Cache.settings.fetch(name)

      # Get the setting from the database
      if val.nil?
        setting = ::Settings::Model::Setting[:name => name.to_s]

        # If the value is also nil we'll use the default value
        if setting.value.nil? or setting.value.empty?
          val = default
        else
          val = setting.value
        end

        ::Ramaze::Cache.settings.store(name, val)
      end

      return unserialize(val)
    end

    ##
    # Retrieves the possible values for the setting. If the value is a Proc or
    # Lambda (or anything else that responds to call()) it will be called and
    # it's return value is used.
    #
    # @since  0.2.8
    # @return [Mixed]
    #
    def values
      if @values.respond_to?(:call)
        return @values.call
      else
        return @values
      end
    end

    ##
    # Returns the parameters for the BlueForm helper.
    #
    # @since  0.3
    # @return [Array]
    #
    def form_parameters
      return BlueFormParameters.send(type, self)
    end

    ##
    # Small helper method that makes it a bit easier to check if a certain
    # setting is set to true or false. Because settings are stored as strings
    # with values of "1" or "0" you'd normally have to do the following:
    #
    #     get_setting(:allow_registration).value == '1'
    #
    # This method allows you to do the following instead:
    #
    #     get_setting(:allow_registration).true?
    #
    # @since  12-11-2011
    # @return [TrueClass|FalseClass]
    #
    def true?
      val = value

      return val.is_a?(String) && val == '1'
    end

    ##
    # Serializes a value using Marshal and packs it so that it can be stored in
    # the database.
    #
    # @since  13-11-2011
    # @param  [Mixed] value The value to serialize.
    # @return [String]
    #
    def serialize(value)
      return [Marshal.dump(value)].pack('m')
    end

    ##
    # Unserializes a value that was serialized using
    # {Settings::Setting#serialize}.
    #
    # @since  13-11-2011
    # @param  [String] value The value to unserialize.
    # @return [Mixed]
    #
    def unserialize(value)
      begin
        return Marshal.load(value.unpack('m')[0])
      rescue
        begin
          return Marshal.load(value)
        rescue
          Ramaze::Log.debug(
            'Failed to unpack the setting using Marshal, using the ' \
              'raw value instead'
          )

          return value
        end
      end
    end
  end # Setting
end # Settings
