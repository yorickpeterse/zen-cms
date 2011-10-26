module Settings
  ##
  # Module that's injected into the global namespace allowing developers to
  # retrieve settings without having to use the full namespace of
  # {Settings::Setting::Registered}.
  #
  # @author Yorick Peterse
  # @since  0.3
  #
  module SingletonMethods
    ##
    # Retrieves the setting for the given name.
    #
    # @example
    #  get_setting(:website_name)
    #
    # @author Yorick Peterse
    # @since  0.3
    # @param  [#to_sym] name The name of the setting to retrieve.
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
