module Zen
  module Controllers
    ##
    # The admin controller is a base controller that should be extended by all controllers
    # for the backend of Zen. This controller will automatically check to see if the user is
    # logged in and perform several other tasks such as loading all Javascript and CSS stylesheet
    # along with our helpers and so on.
    #
    # h2. Authentication
    #
    # It's important to remember that any controller that extends this one will require the
    # user to be logged in. The only exception for this is the login method for the Users
    # controller, mapped to /admin/users/login. If a user isn't logged in he/she will be redirected
    # to the login page.
    #
    # h2. Helpers
    #
    # The admin controller loads the following helpers:
    #
    # * CSRF
    # * BlueForm
    # * Common
    # * Breadcrumb
    # * User
    # * ACL
    # * Asset
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class AdminController < Zen::Controllers::BaseController
      layout :admin
      engine :etanni
      helper :blue_form, :common, :breadcrumb, :user, :acl, :asset
      
      ##
      # The initialize method is called upon class initalization and is used to process several
      # items before loading the controller(s) for the current extension.
      #
      # @author Yorick Peterse
      # @since  1.0
      #
      def initialize
        super
        
        # Load our CSS and Javascript files
        require_css(
          'boilerplate', 'grid', 'layout', 'general', 'forms', 'tables', 'buttons',
          'tabs', 'notifications', 'editor'
        )

        require_js('zen/tabs', 'zen/notification', 'zen/modal', 'zen/editor/base',
          'zen/editor/drivers/html', 'zen/editor/drivers/textile', 'zen/editor/drivers/markdown',
          'zen/init'
        )
        
        # Only allow users to access admin/users/login when they aren't logged in
        if request.env['SCRIPT_NAME'] != 'admin/users/' and request.env['PATH_INFO'] != '/login'
          redirect '/admin/users/login' unless logged_in?
        end

        # Hash containing all available formats for input fields
        @format_hash = {
          'html'     => lang('zen_general.special.format_hash.html'),
          'textile'  => lang('zen_general.special.format_hash.textile'),
          'markdown' => lang('zen_general.special.format_hash.markdown'),
          'plain'    => lang('zen_general.special.format_hash.plain')
        }

        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }.invert

      end
    end
  end
end
