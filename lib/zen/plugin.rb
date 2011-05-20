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
  # ## Creating Plugins
  #
  # Creating a plugin happens in two steps. First you'll create your class and then you'll
  # register it so that it can be used by the system. A plugin has a very simple layout,
  # it's just a class with two methods: initialize and call. The most basic skeleton of a
  # plugin looks like the following:
  #
  #     class MyPlugin
  #       def initialize
  #
  #       end
  #
  #       def call
  #
  #       end
  #     end
  #
  # When a plugin is called all specified arguments are sent to the construct method so if
  # your plugin requires a number of arguments be sure to store them. An example of this
  # looks like the following:
  #
  #     class MyPlugin
  #       def initialize(name)
  #         @name = name
  #       end
  #
  #       def call
  #
  #       end
  #     end
  #
  # The call method is supposed to return some data. Say we want to capitalize a given
  # name we'd modify the skeleton so that it looks like the following:
  #
  #     class MyPlugin
  #       def initialize(name)
  #         @name = name
  #       end
  #
  #       def call
  #         return @name.upcase
  #       end
  #     end
  #
  # ## Registering Plugins
  #
  # Now that the plugin is created it's time to tell Zen it actually is a plugin and not
  # some random class that doesn't belong somewhere. This can be done by calling
  # Zen::Plugin.add and specifying a block with the details of the plugin. Example:
  #
  #     Zen::Plugin.add do |plugin|
  #       plugin.name   = :my_plugin
  #       plugin.author = 'Your name goes in here'
  #       plugin.about  = 'A simple plugin that capitalizes a given string/name'
  #       plugin.plugin = MyPlugin
  #     end
  #
  # The name and plugin setter are the most important. Names should always match the
  # regular expression /[a-z0-9_\-]+/. This is done to ensure names are consistent and
  # easy to remember. It's also used for calling plugins and making sure there are no
  # duplicates.
  #
  # The second important part is the plugin setting. This setter takes the class constant
  # of the plugin that was created earlier on. There's no need to call new(), this will
  # be done by Zen whenever the plugin is actually used.
  #
  # ## Executing Plugins
  #
  # Executing plugins is very easy and can be done by using the global method plugin():
  #
  #     plugin(:my_plugin, 'yorick') # => "YORICK"
  #
  # The first argument is the name of the plugin to call, all following arguments will be
  # sent to the plugin's construct method.
  #
  # @author Yorick Peterse
  # @since  0.2.4
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
