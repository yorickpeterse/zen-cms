module Ramaze
  module Helper
    ##
    # Small helper for the Menus package mainly used to reduce the amount of code
    # in controllers.
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    module MenuItem
      ##
      # Checks if there is a menu for the given ID. If this isn't the case the user
      # will be redirected back to the index page of the menus controller.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Integer] menu_id The ID of the menu to validate.
      #
      def validate_menu(menu_id = nil)
        if !menu_id or ::Menus::Models::Menu[menu_id].nil?
          notification(:error, @menu_items_lang.titles[:index], @menu_items_lang.errors[:invalid_menu])
          redirect(::Menus::Controllers::Menus.r(:index))
        end
      end
    end
  end
end
