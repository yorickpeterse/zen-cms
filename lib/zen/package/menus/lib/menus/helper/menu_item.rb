#:nodoc:
module Ramaze
  #:nodoc:
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
      def validate_menu(menu_id)
        if !menu_id or ::Menus::Model::Menu[menu_id].nil?
          message(:error, @menu_items_lang.errors[:invalid_menu])
          redirect(::Menus::Controller::Menus.r(:index))
        end
      end

      ##
      # Builds a hierarchy of navigation items and all their sub items. The generated
      # structure looks like the following:
      #
      #     Root
      #      |
      #      |_ Sub
      #      | |
      #      | |_ Sub sub
      #      |
      #      |_ Sub 1
      # 
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Integer] menu_id The ID of the current menu group.
      # @return [Hash]
      #
      def menu_item_tree(menu_id)
        menu_items = ::Menus::Model::MenuItem.filter(
          :menu_id   => menu_id, 
          :parent_id => nil
        )

        @menu_items_hash = {nil => '--'}

        menu_items.each do |item|
          @menu_items_hash[item.id] = item.name

          item.descendants.each do |i|
            self.descendant_items(i, 2)
          end
        end

        return @menu_items_hash
      end

      ##
      # Helper method for retrieving descendant navigation items.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Menus::Model::MenuItem] item A MenuItem instance
      # @param  [Integer] spaces The amount of unbreakable spaces to use.
      #
      def descendant_items(item, spaces)
        return if @menu_items_hash.key?(item.id)

        nbsps = ''
        spaces.times { nbsps += "&nbsp;" }
        @menu_items_hash[item.id] = nbsps + item.name
        descendants               = item.descendants

        if !descendants.empty?
          descendants.each do |i|
            self.descendant_items(i, spaces + 2)
          end
        end
      end
    end # MenuItem
  end # Helper
end # Ramaze
