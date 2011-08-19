module Ramaze
  module Helper
    ##
    # Helper that can be used to display various variables based on the user's
    # locale and settings.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    module Locale
      ##
      # Returns the date format for the currently logged in user. If the user
      # has no date format set (or isn't logged in) the system format is used.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      #
      def date_format
        begin
          format = session[:user].date_format
        rescue
          format = plugin(:settings, :get, :date_format).value
        end

        return format
      end
    end # Locale
  end # Helper
end # Ramaze
