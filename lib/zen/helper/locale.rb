module Ramaze
  module Helper
    ##
    # Helper that can be used to display various variables based on the user's
    # locale and settings.
    #
    # @since  0.3
    #
    module Locale
      ##
      # Returns the date format for the currently logged in user. If the user
      # has no date format set (or isn't logged in) the system format is used.
      #
      # @since  0.3
      #
      def date_format
        begin
          format = user.date_format
        rescue
          format = get_setting(:date_format).value
        end

        return format
      end

      ##
      # Formats a date according to Ramaze::Helper::Locale#date_format.
      #
      # @since  0.3
      # @param  [#strftime] object An object that responds to #strftime().
      # @return [String]
      #
      def format_date(object)
        if object.respond_to?(:strftime)
          return object.strftime(date_format)
        else
          return nil
        end
      end
    end # Locale
  end # Helper
end # Ramaze
