#:nodoc:
module Zen
  #:nodoc:
  module Plugin
    ##
    # Module containing various methods that can be used for developing plugins.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    module Helper

      ##
      # Method that can be used to validate the class of a given variable. If the class
      # isn't included in the whitelist an error will be triggered explaining the error.
      #
      # @example
      #  username = 10
      #  validate_type(username, :username, [String]) # => TypeError: "\"username\" can only
      #  be an instance of String but got Integer."
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Mixed] variable The variable to validate.
      # @param  [Symbol/String] name The name of the variable to validate.
      # @param  [Array] whitelist Whitelist of the allowed classes.
      # @raise  TypeError Raised whenever the variable's class wasn't allowed.
      #
      def validate_type(variable, name, whitelist)
        if whitelist.class != Array
          whitelist = [whitelist]
        end

        name    = name.to_s
        classes = whitelist.join(' or ').to_s

        if !whitelist.include?(variable.class)
          raise(
            TypeError, 
            "\"#{name}\" can only be an instance of #{classes} but got #{variable.class}"
          )
        end
      end

    end
  end
end
