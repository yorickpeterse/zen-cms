require __DIR__('error/plugin_error')

#:nodoc:
module Zen
  ##
  # Plugins in Zen are quite similar to packages except for a few differences. The biggest
  # difference is that plugins won't update any Ramaze root directories or language
  # direactories. This means that they can't have controllers, models and so on. On top
  # of that they're nothing more than lambda's. Plugins are useful for supporting multiple
  # markup formats (Markdown, Textile, etc) and other small tasks such as replacing Email
  # addresses and so on.
  #
  # ## Creating Plugins
  #
  # Creating plugins works in a similar way as creating packages. Plugins are added by
  # calling Zen::Plugin#add and passing a block to it with details such as the name of
  # the plugin, the author, the identifier and a list of actions. The last two are very
  # important as the plugin won't work without them.
  #
  # ### Actions
  #
  # Each plugin has a getter/setter called "actions", this is just a simple key/value
  # hash where the keys are the names of the actions and the values lambda's. The keys
  # should always be symbols. Example:
  #
  #     actions = {
  #       :downcase => lambda do |string|
  #         string.downcase
  #       end
  #     }
  #
  # Note that you don't *have to* use lambda's, anything that responds to call() will do.
  # 
  # Because the actions method contains just a hash you can easily add functionality to
  # existing plugins as following:
  #
  #     # First retrieve our plugin
  #     plugin = Zen::Plugin['com.something.plugin.name']
  #     plugin.actions[:my_action] = lamda do
  #       # Do something....
  #     end
  #
  # This can be very useful for extending plugins such as the markup plugin that's used to
  # convert Markdown or Textile to HTML. By default this plugin only converts Markdown and
  # Textile or HTML (it escapes all HTML) but by modifying the actions hash we can easily
  # add new markup engines such as RDoc or even Latex.
  #
  # ## Calling Plugins
  #
  # Plugins can be called using Zen::Plugin#call, this method requires you to specify the
  # plugin identifier, the action to call and optionally any data to send to the plugin.
  # An example of calling a plugin would look like the following:
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
    # @example
    #  Zen::Plugin.add do |p|
    #    p.name    = 'Markup'
    #    p.author  = 'Yorick Peterse'
    #    p.actions = {
    #      :markdown => lambda do |markup|
    #        RDiscount.new(markup).to_html
    #      end 
    #  end
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @yield  [plugin] Struct object containing all the details of a plugin.
    # @raise  [Zen::PluginError] Error raised whenever the plugin already exists or is missing
    # a certain setter.
    #
    def self.add
      @plugins ||= {}
      required   = [:name, :author, :about, :identifier, :actions]
      plugin     = Zen::StrictStruct.new(
        :name, :author, :about, :url, :identifier, :actions
      ).new

      yield plugin

      # Check if all the required keys have been set
      plugin.validate(required) do |k|
        raise(Zen::PluginError, "The following plugin key is missing: #{k}")
      end

      # The actions getter should be a hash
      if plugin.actions.class != Hash
        raise(Zen::PluginError, "The actions setter/getter should be an instance of Hash.")
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
    def self.call(ident, action, *data)
      plugin = self[ident]
      action = action.to_sym

      if !plugin.actions[action]
        raise(Zen::PluginError, "The action #{action} doesn't exist for #{ident}.")
      end

      # Call the plugin and return it's value
      return plugin.actions[action].call(*data)
    end

  end
end
