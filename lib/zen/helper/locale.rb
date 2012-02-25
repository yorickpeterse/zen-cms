module Ramaze
  module Helper
    ##
    # Helper that can be used to display various variables based on the user's
    # locale and settings.
    #
    # ## Working With Dates
    #
    # This module includes two separate methods that can be used for working
    # with dates. The method {Ramaze::Helper::Locale#date_format} can be used to
    # return the raw date format for the currently logged in user, the method
    # {Ramaze::Helper::Locale#format_date} can be used to format an object that
    # responds to ``#strftime()``. It is highly recommended to use the latter
    # method whenever you display dates in order for them to be consistent.
    #
    # Usage of the format_date method is very simple, all you need to do is pass
    # it an object that as mentioned above responds to ``#strftime()``:
    #
    #     format_date(Time.now) # => "23-02-2012 19:08:59"
    #
    # To use this method in Etanni templates you'll have to wrap it in the
    # correct template tags:
    #
    #     #{format_date(Time.now)}
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
