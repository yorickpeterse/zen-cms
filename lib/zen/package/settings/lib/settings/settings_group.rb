module Settings
  ##
  # Base class used for setting groups.
  #
  # @since  0.2.5
  #
  class SettingsGroup
    include ::Zen::Validation

    ##
    # Hash containing all registered setting groups.
    #
    # @since  0.3
    #
    REGISTERED = {}

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
    # @since  0.2.5
    #
    def self.add
      group = self.new

      yield group

      group.validate

      REGISTERED[group.name] = group
    end

    ##
    # Sets the name of the group and converts it to a symbol.
    #
    # @since  0.3
    # @param  [#to_sym] name The name of the settings group.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Returns the title of the setting and tries to translate it.
    #
    # @since  0.3
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
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :title])

      if REGISTERED.key?(name)
        raise(
          ::Zen::ValidationError,
          "The setting group \"#{name}\" has already been registered."
        )
      end
    end
  end # SettingsGroup
end # Settings
