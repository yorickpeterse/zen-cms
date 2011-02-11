module Zen
  module Controllers
    ##
    # The BaseController is extended by both the FrontendController and the BackendController.
    # This controller is mostly used to set and retrieve data that's used in both the
    # backend and the frontend.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class BaseController < Ramaze::Controller
      helper :csrf, :cgi
      
      ##
      # The initialize method is called upon class initalization and is used to process several
      # items before loading the controller(s) for the current module.
      #
      # @author Yorick Peterse
      # @since  1.0
      #
      def initialize
        super
        
        # The trait for the User helper has to be specified in the constructor as
        # our user model is loaded after this class is loaded (but before it's initialized)
        self.trait :user_model => ::Users::Models::User
        
        # Get all settings
        if !session[:settings]
          session[:settings] = ::Settings::Models::Setting.get_settings
        end
        
        # Override the language
        Zen.options.language = session[:settings][:language]
        @zen_general_lang    = Zen::Language.load('zen_general')
      end
    end
  end
end
