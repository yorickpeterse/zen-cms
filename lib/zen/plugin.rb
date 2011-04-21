require __DIR__('error/plugin_error')
require __DIR__('plugin/base')

#:nodoc:
module Zen
  ##
  # Plugins in Zen are quite similar to packages except for a few differences. The biggest
  # difference is that plugins won't update any Ramaze root directories or language
  # directories. This means that they can't have controllers, models and so on. 
  # Plugins are useful for supporting multiple markup formats (Markdown, Textile, etc) 
  # and other small tasks such as replacing Email addresses and so on.
  #
  # @author Yorick Peterse
  # @since  0.2.4
  # @attr_reader [Hash] plugins Hash containing all plugins.
  #
  module Plugin

    ##
    # Hash containing all registered plugins. The keys are the names of the plugins and
    # the values are instances of Zen::Plugin::Base.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Registered = {}

    ##
    # Adds a new plugin with the given details.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @raise  [Zen::PluginError] Error raised whenever the plugin already exists or is 
    # missing a certain setter.
    #
    def self.add
      plugin = Zen::Plugin::Base.new

      yield plugin

      # Validate the plugin
      plugin.validate
      plugin.name = plugin.name.to_sym

      Registered[plugin.name] = plugin
    end

    ##
    # Returns a plugin for the given name.
    #
    # @example
    #  Zen::Plugin[:markup]
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [String] name The name of the plugin to retrieve.
    # @raise  Zen::PluginError Error that's raised when no plugins have been added yet or
    # the specified plugin doesn't exist.
    # @return [Struct] Instance of the plugin.
    #
    def self.[](name)
      if name.class != Symbol
        name = name.to_sym
      end

      if Registered.nil?
        raise(Zen::PluginError, "No plugins have been added.")
      end

      if !Registered[name]
        raise(Zen::PluginError, "The plugin #{name} doesn't exist.")
      end

      return Registered[name]
    end

    #:nodoc:
    module SingletonMethods
      ##
      # Retrieves the given plugin and executes it. All specified parameters will be sent
      # to the plugin as well.
      #
      # @example
      #  plugin(:settings, :get, :language)
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String/Symbol] name The name of the plugin to call.
      # @param  [Array] data Any data to pass to the plugin's action (a lambda).
      # @param  [Proc] block A block that should be passed to the plugin instead of this
      # method.
      # @return [Mixed]
      #
      def plugin(name, *data, &block)
        if name.class != Symbol
          name = name.to_sym
        end

        return ::Zen::Plugin[name].plugin.new(*data, &block).call
      end
    end

  end
end
