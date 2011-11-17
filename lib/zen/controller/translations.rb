module Zen
  module Controller
    ##
    # Controller that generates a Javascript variable containing various
    # language strings that should be available in Javascript code.
    #
    # @since  0.3
    #
    class Translations < Zen::Controller::FrontendController
      map '/admin/js/zen/lib/translations.js'

      # Array containing all the translations to copy.
      TRANSLATIONS = [
        'zen_general.buttons.bold',
        'zen_general.buttons.italic',
        'zen_general.buttons.link',
        'zen_general.buttons.ul',
        'zen_general.buttons.ol',
        'zen_general.buttons.preview',
        'zen_general.buttons.close',
        'zen_general.datepicker.select_a_time',
        'zen_general.datepicker.use_mouse_wheel',
        'zen_general.datepicker.time_confirm_button',
        'zen_general.datepicker.apply_range',
        'zen_general.datepicker.cancel',
        'zen_general.datepicker.week'
      ]

      ##
      # Renders the translations as a Javascript variable. It is a bit of a
      # dirty process but it means I don't have to use the JSON gem which can
      # suck up quite a bit of memory over time.
      #
      # @since 0.3
      #
      def index
        var = 'var Zen = Zen || {}; Zen.translations = {'

        TRANSLATIONS.each do |k|
          var += "'#{k}': '#{lang(k)}',"
        end

        var += '};'

        respond(var, 200, 'Content-Type' => 'text/javascript')
      end
    end # Language
  end # Controller
end # Zen
