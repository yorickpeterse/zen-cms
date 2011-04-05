#:nodoc:
module Menus
  #:nodoc:
  module Controller
    ##
    # Controller for managing individual navigation items that belong to a menu. 
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class MenuItems < ::Zen::Controller::AdminController
      include ::Menus::Model

      map    '/admin/menu-items'
      trait  :extension_identifier => 'com.zen.menus'
      helper :menu_item
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end
 
      ##
      # Initializes the class, loads all language packs and sets the form URLs.
      #
      # This method loads the following language files:
      #
      # * menus
      # * menu_items
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def initialize
        super
 
        @form_save_url   = MenuItems.r(:save)
        @form_delete_url = MenuItems.r(:delete)
        
        Zen::Language.load('menu_items')
        Zen::Language.load('menus')

        # Set the page title based on the current method
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("menu_items.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all navigation items for the current navigation menu.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Integer] menu_id The ID of the current navigation menu.
      #
      def index(menu_id = nil)
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        validate_menu(menu_id)

        set_breadcrumbs(
          anchor_to(lang('menus.titles.index'), Menus.r(:index)), 
          lang('menu_items.titles.index')
        )

        @menu_id    = menu_id
        @menu_items = Menu[menu_id.to_i].menu_items
      end

      ##
      # Allow the user to edit an existing navigation item.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Integer] menu_id The ID of the current navigation menu.
      # @param  [Integer] id The ID of the menu item to edit.
      #
      def edit(menu_id = nil, id)
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        validate_menu(menu_id)

        set_breadcrumbs(
          anchor_to(lang('menus.titles.index'), Menus.r(:index)),
          anchor_to(lang('menu_items.titles.index'), MenuItems.r(:index, menu_id)), 
          lang('menu_items.titles.edit')
        )

        @menu_id = menu_id

        if flash[:form_data]
          @menu_item = flash[:form_data]
        else
          @menu_item = MenuItem[id.to_i]
        end
      end

      ##
      # Allow the user to create a new menu item for the current menu.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Integer] menu_id  The ID of the current navigation menu.
      #
      def new(menu_id = nil)
        if !user_authorized?([:create, :read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end  

        validate_menu(menu_id)

        set_breadcrumbs(
          anchor_to(lang('menus.titles.index'), Menus.r(:index)),
          anchor_to(lang('menu_items.titles.index'), MenuItems.r(:index, menu_id)), 
          lang('menu_items.titles.new')
        )

        @menu_id   = menu_id
        @menu_item = MenuItem.new
      end

      ##
      # Saves an existing menu iten or creates a new one using the supplied POST data. 
      #
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def save
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        post = request.params.dup
        if post['parent_id'].empty? or post['parent_id'] == post['id']
          post['parent_id'] = nil
        end

        # Determine if we're saving changes made to an existing menu item or if we're
        # going to create a new one.
        if !post['id'].empty?
          @menu_item  = MenuItem[post['id'].to_i]
          save_action = :save
        else
          @menu_item  = MenuItem.new
          save_action = :new
        end

        # Set our notifications
        flash_success = lang("menu_items.success.#{save_action}")
        flash_error   = lang("menu_items.errors.#{save_action}")

        # Time to save the data
        begin
          @menu_item.update(post)
          notification(:success, lang('menu_items.titles.index'), flash_success)
        rescue
          notification(:error, lang('menu_items.titles.index'), flash_error)

          flash[:form_data]   = @menu_item
          flash[:form_errors] = @menu_item.errors
        end

        if @menu_item.id
          redirect(MenuItems.r(:edit, @menu_item.menu_id, @menu_item.id))
        else
          redirect_referrer
        end
      end

      ##
      # Delete all specified menu items based on the values in the POST array 
      # "menu_item_ids". This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def delete
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        post = request.params.dup

        if !post['menu_item_ids'] or post['menu_item_ids'].empty?
          notification(
            :error, 
            lang('menu_items.titles.index'), 
            lang('menu_items.errors.no_delete')
          )

          redirect_referrer
        end

        post['menu_item_ids'].each do |id|
          begin
            MenuItem[id.to_i].destroy
          rescue
            notification(
              :error, 
              lang('menu_items.titles.index'), 
              lang('menu_items.errors.delete') % id
            )
            redirect_referrer
          end
        end

        notification(
          :success, 
          lang('menu_items.titles.index'), 
          lang('menu_items.success.delete')
        )

        redirect_referrer
      end
    end
  end
end
