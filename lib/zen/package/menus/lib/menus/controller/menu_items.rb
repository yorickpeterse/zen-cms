module Menus
  #:nodoc:
  module Controller
    ##
    # Managing menu items is divided into two separate parts: specifying the
    # order and hierarchy and editing individual menu items such as their names
    # and URLs. In order to manage a set of menu items you must navigate to the
    # menu to which the items belong and then click on "Manage menu items". Once
    # you've clicked this link you'll be presented with a page that looks
    # somewhat like the one shown in the image below.
    #
    # ![Menu Items](../../images/menus/menu_items.png)
    #
    # This overview allows you to sort and specify the hierarchy of menu items,
    # editing individual items can be done by clicking on the name.
    #
    # Both sorting and creating the hierarchy is done by dragging the menu
    # items. By dragging them up or down you can change the order, by dragging
    # them to the left or right you can specify the parent element of a set of
    # menu items. For example, in the image below the "User Guide" item has been
    # set to be a child item of the "Home" item.
    #
    # ![Menu Item Hierarchy](../../images/menus/menu_item_hierarchy.png)
    #
    # If you want to edit an individual menu item you can do so by clicking on
    # the name of the item, once done you'll be presented with the following
    # form:
    #
    # ![Edit Menu Item](../../images/menus/edit_menu_item.png)
    #
    # In this form you can specify the following fields:
    #
    # * **Name**: the name of the menu item.
    # * **URL**: the URL of the menu item.
    # * **HTML class**: a space separated list of classes to apply to the HTML
    #   element.
    # * **HTML ID**: a single ID to apply to the HTML element.
    #
    # Note that the name, URL, HTML class and HTML ID fields have a maximum
    # length of 255 characters.
    #
    # ## Used Permissions
    #
    # * show_menu_item
    # * new_menu_item
    # * edit_menu_item
    # * delete_menu_item
    #
    # @since  0.2a
    # @map    /admin/menu-items
    #
    class MenuItems <  Zen::Controller::AdminController
      map    '/admin/menu-items'
      helper :menu
      title  'menu_items.titles.%s'

      autosave Model::MenuItem, Model::MenuItem::COLUMNS, :edit_menu_item

      csrf_protection :save, :delete

      serve :css, ['/admin/menus/css/menus'],
        :name    => 'menus',
        :methods => [:index]

      serve :javascript,
        ['/admin/menus/js/lib/nested_sortables', '/admin/menus/js/menu_items'],
        :name    => 'menus',
        :methods => [:index]

      ##
      # Shows an overview of all the menu items for a menu group.
      #
      # @since      0.2a
      # @param      [Fixnum] menu_id The ID of the current navigation menu.
      # @permission show_menu_item
      #
      def index(menu_id)
        authorize_user!(:show_menu_item)

        menu = validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          lang('menu_items.titles.index')
        )

        @menu_id    = menu_id
        @menu_items = Model::Menu[menu_id].menu_items_tree
      end

      ##
      # Allow the user to create a new menu item for the current menu.
      #
      # @since      0.2a
      # @param      [Fixnum] menu_id The ID of the current navigation menu.
      # @permission new_menu_item
      #
      def new(menu_id)
        authorize_user!(:new_menu_item)

        validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          MenuItems.a(lang('menu_items.titles.index'), :index, menu_id),
          lang('menu_items.titles.new')
        )

        @menu_id   = menu_id
        @menu_item = Model::MenuItem.new

        @menu_item.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Allow the user to edit an existing navigation item.
      #
      # @since      0.2a
      # @param      [Fixnum] menu_id The ID of the current navigation menu.
      # @param      [Fixnum] id The ID of the menu item to edit.
      # @permission edit_menu_item
      #
      def edit(menu_id, id)
        authorize_user!(:edit_menu_item)

        validate_menu(menu_id)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          MenuItems.a(lang('menu_items.titles.index'), :index, menu_id),
          lang('menu_items.titles.edit')
        )

        @menu_id   = menu_id
        @menu_item = validate_menu_item(id, menu_id)

        @menu_item.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves an existing menu iten or creates a new one using the supplied
      # POST data.
      #
      # @since      0.2a
      # @permission edit_menu_item (when editing an item)
      # @permission new_menu_item (when creating an item)
      #
      def save
        post = post_fields(*Model::MenuItem::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_menu_item)

          menu_item   = validate_menu_item(id, post['menu_id'])
          save_action = :save
        else
          authorize_user!(:new_menu_item)

          menu_item   = ::Menus::Model::MenuItem.new
          save_action = :new
        end

        success = lang("menu_items.success.#{save_action}")
        error   = lang("menu_items.errors.#{save_action}")

        begin
          menu_item.set(post)
          menu_item.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
          flash[:form_errors] = menu_item.errors

          redirect_referrer
        end

        message(:success, success)
        redirect(MenuItems.r(:edit, menu_item.menu_id, menu_item.id))
      end

      ##
      # Updates the sort order and parent IDs for the given menu items.
      #
      # @since      11-02-2012
      # @permission edit_menu_item
      #
      def tree
        authorize_user!(:edit_menu_item)

        request.POST['menu_items'].each do |item|
          Model::MenuItem[item[1]['id']].update(
            :sort_order => item[0],
            :parent_id  => item[1]['parent_id']
          )
        end
      end

      ##
      # Delete all specified menu items based on the values in the POST array
      # "menu_item_ids".
      #
      # @since      0.2a
      # @permission delete_menu_item
      #
      def delete
        authorize_user!(:delete_menu_item)

        post = post_fields(:menu_item_ids)

        if !post['menu_item_ids'] or post['menu_item_ids'].empty?
          message(:error, lang('menu_items.errors.no_delete'))
          redirect_referrer
        end

        post['menu_item_ids'].each do |id|
          menu = ::Menus::Model::MenuItem[id]

          next if menu.nil?

          begin
            menu.destroy
          rescue => e
            Ramaze::Log.error(e)
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
