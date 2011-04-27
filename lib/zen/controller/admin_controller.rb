#:nodoc:
module Zen
  #:nodoc:
  module Controller
    ##
    # The admin controller is a base controller that should be extended by all controllers
    # for the backend of Zen. This controller will automatically check to see if the 
    # user is logged in and perform several other tasks such as loading all Javascript 
    # and CSS stylesheet along with our helpers and so on.
    #
    # ## Authentication
    #
    # It's important to remember that any controller that extends this one will require 
    # the user to be logged in. The only exception for this is the login method for the 
    # Users controller, mapped to /admin/users/login. If a user isn't logged in he/she 
    # will be redirected to the login page.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class AdminController < Zen::Controller::BaseController
      layout :admin
      engine :etanni
      helper :blue_form, :common, :breadcrumb, :user, :acl

      ##
      # The initialize method is called upon class initalization and is used to process several
      # items before loading the controller(s) for the current extension.
      #
      # @author Yorick Peterse
      # @since  1.0
      #
      def initialize
        super
                
        # Only allow users to access admin/users/login when they aren't logged in
        if request.env['SCRIPT_NAME'] != 'admin/users/' and request.env['PATH_INFO'] != '/login'
          redirect '/admin/users/login' unless logged_in?
        end

        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }.invert
      end
 
      ##
      # Shortcut for Zen::Asset.stylesheet.
      #
      # @author Yorick Peterse
      # @see    Zen::Asset.stylesheet
      # @since  0.2.5
      #
      def self.stylesheet(files, options = {})
        options = {
          :controller => self
        }.merge(options)

        ::Zen::Asset.stylesheet(files, options)
      end

      ##
      # Shortcut for Zen::Asset.javascript.
      #
      # @author Yorick Peterse
      # @see    Zen::Asset.javascript
      # @since  0.2.5
      #
      def self.javascript(files, options = {})
        options = {
          :controller => self
        }.merge(options)

        ::Zen::Asset.javascript(files, options)
      end

      # Load all stylesheets globally
      stylesheet(
        [
          'reset', 'grid', 'layout', 'general', 'forms', 'tables', 'buttons', 'tabs', 
          'notifications'
        ], 
        :global => true
      )

      # Load all global javascript files
      javascript(
        [
          'mootools/core', 'mootools/more', 'zen/tabs', 'zen/notification', 'zen/init'
        ],
        :global => true
      )

    end
  end
end
