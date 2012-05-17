module Zen
  module Spec
    module Helper
      ##
      # Module providing various helper methods for Capybara based tests.
      #
      # @since 2012-02-18
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
        # Automatically saves a form with the given ID.
        #
        # @since 2012-02-18
        # @param [String] id The ID of the form.
        #
        def autosave_form(id)
          page.evaluate_script(
            "new Zen.Autosave(
              $('#{id}'),
              $('#{id}').get('data-autosave-url'),
              {interval: 1000}
            );"
          )

          sleep(2.5)

          page.has_selector?('span.error').should == false
        end

        ##
        # Switches Capybara's driver to the default Javascript driver.
        #
        # @since 2012-02-18
        #
        def enable_javascript
          WebMock.disable!

          ::Capybara.current_driver = ::Capybara.javascript_driver

          capybara_login
        end

        ##
        # Switches Capybara's driver back to the default driver.
        #
        # @since 2012-02-18
        #
        def disable_javascript
          ::Capybara.use_default_driver
          WebMock.enable!
        end
      end # Capybara
    end # Helper
  end # Spec
end # Zen
