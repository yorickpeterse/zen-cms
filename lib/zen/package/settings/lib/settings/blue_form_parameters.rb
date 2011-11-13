module Settings
  ##
  # {Settings::BlueFormParameters} is a module used to build the required
  # parameters for various settings. These parameters will be passed to
  # ``Ramaze::Helper::BlueForm`` similar to how
  # {CustomFields::BlueFormParameters} does this.
  #
  # Similar to the custom fields module mentioned above adding methods to this
  # module is relatively easy (though you usually don't need to add your own
  # methods). This can be done by simply re-opening the module and adding a
  # class method to it:
  #
  #     module Settings
  #       module BlueFormParameters
  #         def self.custom_method(setting)
  #
  #         end
  #       end
  #     end
  #
  # Each method receives an instance of {Settings::Setting} and should return an
  # array. This array contains the required parameters that will be sent to the
  # BlueForm helper.
  #
  # @since 0.3
  #
  module BlueFormParameters
    class << self
      ##
      # Generates the required parameters for a textbox (``input type="text"``).
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters
      # @return [Array]
      #
      def textbox(setting)
        return [
          :input_text,
          setting.title,
          setting.name,
          :value => setting.value
        ]
      end

      ##
      # Generates the required parameters for a text area.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters.
      # @return [Array]
      #
      def textarea(setting)
        return [
          :textarea,
          setting.title,
          setting.name,
          :value => setting.value,
          :rows  => 8
        ]
      end

      ##
      # Generates the required parameters for a radio button.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters.
      # @return [Array]
      #
      def radio(setting)
        return [
          :input_radio,
          setting.title,
          setting.name,
          setting.value,
          :values => setting.values
        ]
      end

      ##
      # Generates the required parameters for a checkbox.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters.
      # @return [Array]
      #
      def checkbox(setting)
        return [
          :input_checkbox,
          setting.title,
          setting.name,
          setting.value,
          :values => setting.values
        ]
      end

      ##
      # Generates the required parameters for a select box.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for whcih to generate the
      #  parameters.
      # @return [Array]
      #
      def select(setting)
        return [
          :select,
          setting.title,
          setting.name,
          :values   => setting.values,
          :size     => 1,
          :selected => setting.value
        ]
      end

      ##
      # Generates the parameters for a select box that allows users to select
      # multiple values.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters.
      # @return [Array]
      #
      def select_multiple(setting)
        params                = select(setting)
        params[-1][:multiple] = :multiple
        params[-1].delete(:size)

        return params
      end

      ##
      # Generates the parameters for a date field.
      #
      # @since 0.3
      # @param [Settings::Setting] setting The setting for which to generate the
      #  parameters.
      # @return [Array]
      #
      def date(setting)
        params             = textbox(setting)
        params[-1][:class] = 'date'

        return params
      end
    end
  end # BlueFormParameters
end # Settings
