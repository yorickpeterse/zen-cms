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
    class MenuItems <  Zen::Controller::AdminController
      map '/admin/menu-items'
      helper :menu

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
        @page_title = lang("menu_items.titles.#{action.method}") rescue nil
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
      # @param  [Fixnum] menu_id The ID of the current navigation menu.
      #
      def index(menu_id)
        require_permissions(:show_menu_item)

        menu = validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          lang('menu_items.titles.index')
        )

        @menu_id    = menu_id
        @menu_items = ::Menus::Model::MenuItem.filter(:menu_id => menu_id)
        @menu_items = paginate(@menu_items)
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
      # @param  [Fixnum] menu_id The ID of the current navigation menu.
      # @param  [Fixnum] id The ID of the menu item to edit.
      #
      def edit(menu_id, id)
        require_permissions(:edit_menu_item)

        validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          MenuItems.a(lang('menu_items.titles.index'), :index, menu_id),
          lang('menu_items.titles.edit')
        )

        @menu_id = menu_id

        if flash[:form_data]
          @menu_item = flash[:form_data]
        else
          @menu_item = validate_menu_item(id, menu_id)
        end

        render_view(:form)
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
      # @param  [Fixnum] menu_id  The ID of the current navigation menu.
      #
      def new(menu_id)
        require_permissions(:new_menu_item)

        validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          MenuItems.a(lang('menu_items.titles.index'), :index, menu_id),
          lang('menu_items.titles.new')
        )

        @menu_id   = menu_id
        @menu_item = ::Menus::Model::MenuItem.new

        render_view(:form)
      end

      ##
      # Saves an existing menu iten or creates a new one using the supplied
      # POST data.
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
        post = request.subset(
          :id,
          :parent_id,
          :name,
          :url,
          :sort_order,
          :html_class,
          :html_id,
          :menu_id
        )

        if post['parent_id'].empty? or post['parent_id'] === post['id']
          post['parent_id'] = nil
        end

        # Determine if we're saving changes made to an existing menu item or
        # if we're going to create a new one.
        if post.key?('id') and !post['id'].empty?
          require_permissions(:edit_menu_item)

          @menu_item  = validate_menu_item(post['id'], post['menu_id'])
          save_action = :save
        else
          require_permissions(:new_menu_item)

          @menu_item  = ::Menus::Model::MenuItem.new
          save_action = :new
        end

        post.delete('id')

        # Set our notifications
        flash_success = lang("menu_items.success.#{save_action}")
        flash_error   = lang("menu_items.errors.#{save_action}")

        # Time to save the data
        begin
          @menu_item.update(post)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = @menu_item
          flash[:form_errors] = @menu_item.errors

          redirect_referrer
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
        require_permissions(:delete_menu_item)

        post = request.subset(:menu_item_ids)

        if !post['menu_item_ids'] or post['menu_item_ids'].empty?
          message(:error, lang('menu_items.errors.no_delete'))
          redirect_referrer
        end

        post['menu_item_ids'].each do |id|
          begin
            ::Menus::Model::MenuItem[id].destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('menu_items.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('menu_items.success.delete'))
        redirect_referrer
      end
    end # MenuItems
  end # Controller
end # Menus
