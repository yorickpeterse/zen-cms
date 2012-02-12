module Ramaze
  #:nodoc:
  module Helper
    ##
    # Small helper for the Menus package mainly used to reduce the amount of
    # code in controllers.
    #
    # @since  0.2a
    #
    module Menu
      ##
      # Checks if there is a menu for the given ID. If this isn't the case the
      # user will be redirected back to the index page of the menus controller.
      #
      # @since  0.2a
      # @param  [Fixnum] menu_id The ID of the menu to validate.
      # @return [Menus::Model::Menu] The menu that was specified in case it's
      #  valid.
      #
      def validate_menu(menu_id)
        menu = ::Menus::Model::Menu[menu_id]

        if menu.nil?
          message(:error, lang('menus.errors.invalid_menu'))
          redirect(::Menus::Controller::Menus.r(:index))
        else
          return menu
        end
      end

      ##
      # Validates a menu item and returns it if it's valid.
      #
      # @since  0.2.8
      # @param  [Fixnum] menu_item_id The ID of the menu item to validate.
      # @param  [Fixnum] menu_id The ID of the menu the item belongs to, used
      #  when redirecting the user.
      # @return [Menus::Model::MenuItem]
      #
      def validate_menu_item(menu_item_id, menu_id)
        menu_item = ::Menus::Model::MenuItem[menu_item_id]

        if menu_item.nil?
          message(:error, lang('menu_items.errors.invalid_item'))
          redirect(::Menus::Controller::MenuItems.r(:index, menu_id))
        else
          return menu_item
        end
      end

      ##
      # Builds the menu item tree that can be used by the user to edit the sort
      # order, create the menu item tree and edit individual menu items.
      #
      # @since  11-02-2012
      # @param  [Array] tree The menu item tree to process. This array should be
      #  in the format as returned by {Menus::Model::Menu#menu_items_tree}.
      # @return [String]
      #
      def menu_items_tree(tree)
        gestalt = Ramaze::Gestalt.new
        params  = {:id => 'menu_items'}

        unless user_authorized?(:edit_menu_item)
          params[:'data-editable'] = false
        end

        gestalt.ul(params) do
          tree.each do |item|
            menu_item(item, gestalt)
          end
        end

        return gestalt.to_s
      end

      private

      ##
      # Builds the HTML for a single menu item and recursively calls itself for
      # any sub menu items.
      #
      # @since 11-02-2012
      # @param [Hash] item A single menu item to process.
      # @param [Ramaze::Gestalt] gestalt An instance of Ramaze::Gestalt to use
      #  for building the HTML.
      #
      def menu_item(item, gestalt)
        gestalt.li(:id => "menu_item_#{item[:node].id}") do
          gestalt.div(:class => 'menu_item') do

            if user_authorized?(:delete_menu_item)
              gestalt.input(
                :type  => 'checkbox',
                :name  => 'menu_item_ids[]',
                :value => item[:node].id
              )
            end

            if user_authorized?(:edit_menu_item)
              edit_link(
                Menus::Controller::MenuItems.r(
                  :edit,
                  item[:node].menu_id,
                  item[:node].id
                ),
                item[:node].name
              )
            else
              item[:node].name
            end
          end

          unless item[:children].empty?
            gestalt.ul do
              item[:children].each do |child|
                menu_item(child, gestalt)
              end
            end
          end
        end
      end
    end # MenuItem
  end # Helper
end # Ramaze
