#:nodoc:
module Settings
  #:nodoc:
  module Plugin
    ##
    # Base class used for individual settings.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class SettingBase
      include ::Zen::Validation

      ##
      # Array containing all possible setting types.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      Types = [
        'textbox', 'textarea', 'radio', 'checkbox', 'date', 'select', 'select_multiple'
      ]

      # The name of the setting
      attr_accessor :name
      
      # The title of the setting, displayed in the GUI
      attr_accessor :title
      
      # A small description about the setting
      attr_accessor :description
      
      # The name of the settings group this setting belongs to
      attr_accessor :group
      
      # The type of setting (e.g. textbox)
      attr_accessor :type
      
      # The possible values for the setting
      attr_accessor :values
      
      # The default value of the setting
      attr_accessor :default

      ##
      # Validates all attributes of this class.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def validate
        validates_presence([:name, :title, :group, :type])

        # Validate the setting type
        if !Types.include?(type)
          raise(::Zen::ValidationError, "The setting type #{type} is invalid.")
        end

        # Check if the setting hasn't been registered yet
        if ::Settings::Plugin::Settings::Registered[:settings].key?(name)
          raise(
            ::Zen::ValidationError,
            "The setting #{name} has already been registered"
          )
        end

        # Validate the group
        if !::Settings::Plugin::Settings::Registered[:groups].key?(group)
          raise(::Zen::ValidationError, "The settings group #{group} doesn't exist.")
        end
      end

      ##
      # Updates the value of a setting both in the cache and the SQL database.
      #
      # @author Yorick Peterse
      # @since  0.2.6.1
      # @param  [String] value The value to set the setting to.
      #
      def value=(value)
        # First we'll update the SQL database
        ::Settings::Model::Setting[:name => name].update(:value => value)

        # Sync the cache
        ::Ramaze::Cache.settings.store(name, value)
      end

      ##
      # Retrieves the setting. If it exists in the cache the cache's value is used,
      # otherwise it will be retrieved from the SQL database and cached.
      #
      # @author Yorick Peterse
      # @since  0.2.6.1
      #
      def value
        val = ::Ramaze::Cache.settings.fetch(name)

        # Get the setting from the database
        if val.nil?
          setting = ::Settings::Model::Setting[:name => name]

          # If the value is also nil we'll use the default value
          if setting.value.nil? or setting.value.empty?
            val = setting.default
          else
            val = setting.value
          end

          ::Ramaze::Cache.settings.store(name, val)
        end

        return val
      end
    end # SettingBase
  end # Plugin
end # Settings
