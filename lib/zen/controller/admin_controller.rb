#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The admin controller is a base controller that should be extended by all
    # controllers for the backend of Zen. This controller will automatically
    # check to see if the user is logged in and perform several other tasks such
    # as loading all Javascript and CSS stylesheet along with our helpers and
    # so on.
    #
    # ## Authentication
    #
    # It's important to remember that any controller that extends this one will
    # require the user to be logged in. The only exception for this is the login
    # method for the Users controller, mapped to /admin/users/login. If a user
    # isn't logged in he/she will be redirected to the login page.
    #
    # @since  0.1
    #
    class AdminController < Zen::Controller::BaseController
      layout :admin
      engine :etanni
      helper :breadcrumb, :asset, :search
    end # AdminController
  end # Controller
end # Zen
