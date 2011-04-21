#:nodoc:
module Zen
  module Plugin
    ##
    # Base class used to store the data about plugins such as the name, plugin class, etc.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Base
      include ::Zen::Validation

      # The name of the plugin
      attr_accessor :name

      # The author of the plugin
      attr_accessor :author

      # A small description of the plugin
      attr_accessor :about

      # The URL to the plugin's website
      attr_accessor :url

      # The class of the plugin
      attr_accessor :plugin

      ##
      # Validates all the attributes.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def validate
        validates_presence([:name, :author, :about, :plugin])
        validates_format(:name, /[a-z0-9_\-]+/)

        # Check if the theme doesn't exist
        if ::Zen::Plugin::Registered.key?(name.to_sym)
          raise(::Zen::ValidationError, "The plugin #{name} already exists.")
        end
      end
    end
  end
end
