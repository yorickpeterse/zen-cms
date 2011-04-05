require __DIR__('error/plugin_error')

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
  # Creating plugins works in a similar way as creating packages. Plugins are added by
  # calling Zen::Plugin#add and passing a block to it with details such as the name of
  # the plugin, the author, the identifier and a class constant to use. The last two are 
  # very important as the plugin won't work without them. This looks something like the 
  # following:
  #
  #     Zen::Plugin.add do |p|
  #       p.name       = 'My Plugin'
  #       p.author     = 'Yorick Peterse'
  #       p.about      = 'A simple plugin that does something useful.'
  #       p.identifier = 'com.zen.plugin.my_plugin'
  #       p.plugin     = MyPlugin
  #     end
  #
  # One of the most important parts is the `p.plugin = MyPlugin` part. That line tells Zen
  # what class it should use when the plugin is called. Each plugin class should have the
  # following basic structure:
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
  # When a plugin is called all the data passed to the call() method is sent to the class'
  # construct method (so be sure to accept any arguments). Once an instance has been
  # created the call method will be invoked. For a good example on how a plugin looks like
  # take a look at Zen::Plugin::Markup.
  #
  # ## Calling Plugins
  #
  # Plugins can be called using Zen::Plugin#call, this method requires you to specify the
  # plugin identifier and optionally any data to send to the plugin. An example of 
  # calling a plugin would look like the following:
  #
  #     Zen::Plugin.call('com.zen.plugin.markup', :markdown, 'hello **world**')
  #
  # ## Identifiers
  #
  # Plugin identifiers should always have the following format:
  #
  #     com.VENDOR.plugin.NAME
  #
  # For example:
  #
  #     com.zen.plugin.markup
  #
  # @author Yorick Peterse
  # @since  0.2.4
  # @attr_reader [Hash] plugins Hash containing all plugins.
  #
  module Plugin
    class << self
      attr_reader :plugins
    end

    ##
    # Adds a new plugin with the given details.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @yield  [plugin] Struct object containing all the details of a plugin.
    # @raise  [Zen::PluginError] Error raised whenever the plugin already exists or is missing
    # a certain setter.
    #
    def self.add
      @plugins ||= {}
      required   = [:name, :author, :about, :identifier, :plugin]
      plugin     = Zen::StrictStruct.new(
        :name, :author, :about, :url, :identifier, :plugin
      ).new

      yield plugin

      # Check if all the required keys have been set
      plugin.validate(required) do |k|
        raise(Zen::PluginError, "The following plugin key is missing: #{k}")
      end

      # Add our plugin
      if !@plugins[plugin.identifier].nil?
        raise(Zen::PluginError, "The plugin #{plugin.name} already exists.")
      end

      @plugins[plugin.identifier] = plugin
    end

    ##
    # Returns a plugin for the given identifier.
    #
    # @example
    #  Zen::Plugin['com.zen.plugin.markup']
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [String] ident The plugin identifier.
    # @raise  Zen::PluginError Error that's raised when no plugins have been added yet or
    # the specified plugin doesn't exist.
    # @return [Struct] Instance of the plugin.
    #
    def self.[](ident)
      if @plugins.nil?
        raise(Zen::PluginError, "No plugins have been added.")
      end

      if !@plugins[ident]
        raise(Zen::PluginError, "The plugin #{ident} doesn't exist.")
      end

      return @plugins[ident]
    end

    ##
    # Calls the plugin for the given identifier and executes the action.
    #
    # @example
    #  Zen::Plugin.call('com.zen.foobar', :markdown, 'hello **world**')
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [String] ident The plugin identifier.
    # @param  [Symbol] action The plugin action to call.
    # @param  [Array] data Any data to pass to the plugin's action (a lambda).
    # @return [Mixed]
    #
    def self.call(ident, *data)
      return self[ident].plugin.new(*data).call
    end

  end
end
