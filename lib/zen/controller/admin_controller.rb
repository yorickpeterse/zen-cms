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
    # @author Yorick Peterse
    # @since  0.1
    #
    class AdminController < Zen::Controller::BaseController
      layout :admin
      engine :etanni
      helper :breadcrumb, :paginate, :asset

      # Configure the pagination
      trait :paginate => {
        :limit => 20,
        :var   => 'page'
      }

      ##
      # The initialize method is called upon class initalization and is used to
      # process several items before loading the controller(s) for the current
      # extension.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        # Only allow users to access admin/users/login when they aren't logged
        # in
        if request.env['SCRIPT_NAME'] != 'admin/users/' \
        and request.env['PATH_INFO']  != '/login' \
        and !logged_in?
          message(:error, lang('zen_general.errors.require_login'))
          redirect('/admin/users/login')
        end
      end
    end # AdminController
  end # Controller
end # Zen
