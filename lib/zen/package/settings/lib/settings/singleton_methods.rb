module Settings
  ##
  # Module that's injected into the global namespace allowing developers to
  # retrieve settings without having to use the full namespace of
  # {Settings::Setting::Registered}.
  #
  # @since  0.3
  #
  module SingletonMethods
    ##
    # Retrieves the setting for the given name. This method returns an instance
    # of {Settings::Setting}, this means that in order to retrieve the actual
    # value you'll have to invoke ``#value()`` on the return value.
    #
    # @example
    #  get_setting(:website_name) # => #<Settings::Setting>
    #
    # @example Retrieving the value
    #  get_setting(:website_name) # => "Example"
    #
    # @since  0.3
    # @param  [#to_sym] name The name of the setting to retrieve.
    # @return [Settings::Setting]
    #
    def get_setting(name)
      name = name.to_sym

      if !Settings::Setting::Registered.key?(name)
        raise(ArgumentError, "The setting \"#{name}\" doesn't exist.")
      end

      return Settings::Setting::Registered[name]
    end
  end # SingletonMethods
end # Settings
