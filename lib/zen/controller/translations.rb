module Zen
  module Controller
    ##
    # Controller that serves a JSON object in a Javascript variable. This JSON
    # object contains all the translations for the current language.
    #
    # @author Yorick Peterse
    # @since  0.3
    #
    class Translations < Zen::Controller::FrontendController
      map '/admin/js/zen/lib/translations.js'

      ##
      # Renders the translations as a Javascript variable.
      #
      # @author Yorick Peterse
      # @since  0.3
      #
      def index
        lang = JSON.dump(Zen::Language::Translations[Zen::Language.current])

        respond(
          "Zen.translations = #{lang};",
          200,
          'Content-Type' => 'text/javascript'
        )
      end
    end # Language
  end # Controller
end # Zen
