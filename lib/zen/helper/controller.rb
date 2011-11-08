module Ramaze
  module Helper
    ##
    # Helper that provides a few methods for commonly used code inside a
    # controller.
    #
    # @since  0.3
    #
    module Controller
      ##
      # Extends the class that included this module with the ClassMethods
      # module.
      #
      # @since  0.3
      # @param  [Class] into The class that included this module.
      #
      def self.included(into)
        into.extend(Ramaze::Helper::Controller::ClassMethods)
      end

      ##
      # Methods that become available as class methods.
      #
      # @since  0.3
      #
      module ClassMethods
        ##
        # Sets the title for all the methods based on a language string. If
        # there's no corresponding language key the title will not be set.
        #
        # @example
        #  class Foo < Zen::Controller::AdminController
        #    title 'foo.titles.%s'
        #  end
        #
        # @since  0.3
        # @param  [String] title The language key to use, a %s will be replaced
        #  with the name of the current action.
        #
        def title(title)
          stacked_before_all(:set_page_title) do
            @page_title = lang(title % action.method) rescue nil
          end
        end

        ##
        # Protects the specified methods against CSRF attacks. If a CSRF token
        # is missing the user will see the message defined in the language key
        # "zen_general.errors.csrf" and the HTTP status code will be set to 403.
        #
        # @example
        #  class Foo < Zen::Controller::AdminController
        #    csrf_protection :save, :delete
        #  end
        #
        # @since  0.3
        # @param  [Array] *actions An array of action names to protect against
        #  CSRF attacks.
        #
        def csrf_protection(*actions)
          # before_all() calls don't stack. Because CSRF protected methods are
          # usually used for POST calls (and are separate methods) this works
          # around it.
          stacked_before_all(:validate_csrf_token) do
            csrf_protection(*actions) do
              respond(lang('zen_general.errors.csrf'), 403)
            end
          end
        end
      end # ClassMethods
    end # Controller
  end # Helper
end # Ramaze
