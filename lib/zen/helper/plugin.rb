require __DIR__('../error/plugin_error.rb')

#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper that makes it easier to call plugins from controllers and templates.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    module Plugin

      ##
      # Tries to find a plugin where the last segment matches the given name. By default
      # this method will loop over all plugins and try to match the last segment, this
      # can become a problem if there are N plugins where the last segment is the same
      # but other parts aren't (e.g. the vendor name) as illustrated here:
      #
      #     com.yorickpeterse.plugin.section_entries
      #     com.zen.plugin.section_entries
      #
      # If you want to retrieve a plugin from a specific vendor to work around this issue
      # you should set the first argument of this method to an array where index 0 is the
      # vendor name and index 1 the last segment of the identifier:
      #
      #     plugin([:yorick, :section_entries], :entry => 'home')
      #
      # @example
      #  entry = plugin(:section_entries, :entry => 'home')
      #  entry = plugin([:zen, :section_entries], :entry => 'home'
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String/Symbol/Array] selector Defines how the plugin should be retrieved.
      # @param  [Array] args Array with all additional arguments that will be passed to
      # the plugin.
      # @return [Mixed]
      #
      def plugin(selector, *args)
        if Zen::Plugin.plugins.nil?
          throw(Zen::PluginError, "No plugins have been registered yet.")
        end

        Zen::Plugin.plugins.each do |ident, p|
          ident = ident.to_s.split('.')

          # [0]: "com"
          # [1]: vendor's name
          # [2]: "plugin"
          # [3]: should theoratically contain the plugin name,  we'll use the last segment
          # just to be sure.
          segment = ident.last.to_s

          if selector.class == Array
            vendor = selector[0].to_s
            plugin = selector[0].to_s

            # Call the plugin
            if ident.include?(vendor) and ident.include?(plugin)
              return Zen::Plugin.call(p.identifier, *args)
            end
          else
            if selector.to_s === segment
              return Zen::Plugin.call(p.identifier, *args)
            end
          end
        end

        throw(Zen::PluginError, "No plugins were found for #{selector.to_s}")
      end

    end
  end
end
