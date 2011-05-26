#:nodoc:
module Settings
  #:nodoc:
  module Plugin
    ##
    # Base class used for setting groups.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class GroupBase
      include ::Zen::Validation

      # The name of the group
      attr_accessor :name

      # The title of the group, displayed in the GUI
      attr_accessor :title

      ##
      # Validates all attributes of this class.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def validate
        validates_presence([:name, :title])
        validates_format(:name, /[a-z0-9_\-]+/)

        if ::Settings::Plugin::Settings::Registered[:groups].key?(name)
          raise(
            ::Zen::ValidationError,
            "The setting group #{name} has already been registered."
          )
        end
      end
    end # GroupBase
  end # Plugin
end # Settings
