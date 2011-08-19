#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The BaseController is extended by both the FrontendController and the
    # BackendController. This controller is mostly used to set and retrieve
    # data that's used in both the backend and the frontend.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class BaseController < Ramaze::Controller
      helper :user, :csrf, :message, :cgi, :locale
    end # BaseController
  end # Controller
end # Zen
