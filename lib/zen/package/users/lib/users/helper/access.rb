module Ramaze
  module Helper
    ##
    # Whenever this module is included into a controller *all* its methods
    # require the user to be logged in. If you want to make certain methods
    # available to non logged in users you can do so using
    # {Ramaze::Helper::Access::ClassMethods#allow}:
    #
    #     class Users < Zen::Controller::AdminController
    #       allow [:login]
    #
    #       def login
    #
    #       end
    #     end
    #
    # @since 05-11-2011
    #
    module Access
      # Hash containing various controllers and methods that the user can access
      # without logging in.
      PUBLIC_ACTIONS = {}

      ##
      # Called whenever this module is included into a controller.
      #
      # @since 05-11-2011
      #
      def self.included(into)
        into.extend(ClassMethods)
      end

      ##
      # Module that contains various class methods for the including controller.
      #
      # @since 05-11-2011
      #
      module ClassMethods
        ##
        # Called whenever the class that included this module is extended.
        #
        # @since 07-11-2011
        # @param [Class] by The class that extended the current class.
        #
        def inherited(by)
          by.stacked_before_all(:validate_user_login) do
            deny   = true
            klass  = self.class
            method = action.method

            if method
              method = method.to_sym

              if PUBLIC_ACTIONS.key?(klass) \
              and PUBLIC_ACTIONS[klass].include?(method)
                deny = false
              end

              if deny == true and logged_in? == false
                message(:error, lang('zen_general.errors.require_login'))
                redirect(::Users::Controller::Users.r(:login))
              end
            end
          end
        end

        ##
        # Allows users to access the given methods without having to log in.
        #
        # @example
        #  class Users < Zen::Controller::AdminController
        #    allow [:login]
        #
        #    # The user can access this method without having to log in.
        #    def login
        #
        #    end
        #  end
        #
        # @since 05-11-2011
        # @param [Array] actions An array of action names that users can access.
        #
        def allow(actions)
          actions = actions.map { |a| a.to_sym  }

          Ramaze::Helper::Access::PUBLIC_ACTIONS[self] ||= []
          Ramaze::Helper::Access::PUBLIC_ACTIONS[self]  += actions
        end
      end # ClassMethods
    end # Access
  end # Helper
end # Ramaze
