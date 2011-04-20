#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The BaseController is extended by both the FrontendController and the 
    # BackendController. This controller is mostly used to set and retrieve data that's 
    # used in both the backend and the frontend.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class BaseController < Ramaze::Controller
      include ::Zen::Language

      helper :csrf, :cgi, :plugin
      
      ##
      # The initialize method is called upon class initalization and is used to 
      # process several items before loading the controller(s) for the current module.
      #
      # @author Yorick Peterse
      # @since  1.0
      #
      def initialize
        super

        # Get all settings
        if !@settings
          @settings = ::Settings::Model::Setting.get_settings
        end

        # Override the language
        if @settings[:language] != ::Zen::Language.options.language
          ::Zen::Language.options.language = @settings[:language]
          ::Zen::Language.load('zen_general')
        end
      end
    end
  end
end
