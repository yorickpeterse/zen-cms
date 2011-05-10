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

      helper :csrf, :cgi
      
      ##
      # The initialize method is called upon class initialization and is used to 
      # process several items before loading the controller(s) for the current module.
      #
      # @author Yorick Peterse
      # @since  1.0
      #
      def initialize
        super

        # Store the settings data if this is the first time we're loading the controller
        if ::Zen::Settings.empty?
          ::Settings::Model::Setting.get_settings.each do |k, v|
            ::Zen::Settings[k] = v
          end
        end
      end
    end
  end
end
