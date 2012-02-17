module Zen
  module Spec
    module Helper
      ##
      # Module providing various helper methods for Capybara based tests.
      #
      # @since 18-02-2012
      #
      module Capybara
        ##
        # Logs the user in using the spec user.
        #
        # @since  0.2.8
        #
        def capybara_login
          # Log the user in
          login_url     = ::Users::Controller::Users.r(:login).to_s
          dashboard_url = ::Sections::Controller::Sections.r(:index).to_s

          visit(login_url)
          ::Ramaze::Log.loggers.clear

          within('#login_form') do
            fill_in('Email'   , :with => 'spec@domain.tld')
            fill_in('Password', :with => 'spec')
            click_button('Login')
          end
        end

        ##
        # Switches Capybara's driver to the default Javascript driver.
        #
        # @since 18-02-2012
        #
        def enable_javascript
          WebMock.disable!

          ::Capybara.current_driver = ::Capybara.javascript_driver

          capybara_login
        end

        ##
        # Switches Capybara's driver back to the default driver.
        #
        # @since 18-02-2012
        #
        def disable_javascript
          ::Capybara.use_default_driver
          WebMock.enable!
        end
      end # Capybara
    end # Helper
  end # Spec
end # Zen
