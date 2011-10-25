module Settings
  ##
  # Base class used for setting groups.
  #
  # @author Yorick Peterse
  # @since  0.2.5
  #
  class SettingsGroup
    include ::Zen::Validation

    ##
    # Hash containing all registered setting groups.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    Registered = {}

    # The name of the group
    attr_reader :name

    # The title of the group, displayed in the GUI
    attr_writer :title

    ##
    # Registers a new setting group using the specified block.
    #
    # @example
    #  Settings::SettingsGroup.add do |group|
    #    group.name  = 'example'
    #    group.title = 'Example group'
    #  end
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    def self.add
      group = self.new

      yield group

      group.validate

      Registered[group.name] = group
    end

    ##
    # Sets the name of the group and converts it to a symbol.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] name The name of the settings group.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Returns the title of the setting and tries to translate it.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @return [String]
    #
    def title
      begin
        return lang(@title)
      rescue
        return @title
      end
    end

    ##
    # Validates all attributes of this class.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :title])

      if Registered.key?(name)
        raise(
          ::Zen::ValidationError,
          "The setting group \"#{name}\" has already been registered."
        )
      end
    end
  end # SettingsGroup
end # Settings
