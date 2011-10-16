module Menus
  #:nodoc:
  module Controller
    ##
    # The MenuItems controller allows users to manage menu items of a menu
    # group. In order to manage menu items you must first navigate to a menu
    # group and click the link "Manage menu items" (see
    # {Menus::Controller::Menus} for more information). Once you've reached this
    # page you'll see an overview that looks like the image below.
    #
    # ![Menu Items](../../_static/menus/menu_items.png)
    #
    # Editing or creating a menu item can be done by either clicking the name of
    # a menu item or by clicking the "Add menu item" button. In both cases
    # you'll end up with a form looking like the one in the following image:
    #
    # ![Edit Menu Item](../../_static/menus/edit_menu_item.png)
    #
    # In this form you can specify the following fields:
    #
    # * **Name**: the name of the menu item.
    # * **URL**: the URL of the menu item.
    # * **Order**: a number that indicates the sort order when the menu is
    #   built.
    # * **Parent**: a parent menu item. This allows you to easily create sub
    #   menus.
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
    # ## Events
    #
    # All events in this controller receive an instance of
    # {Menus::Model::MenuItem}. Just like other packages the event
    # ``delete_menu_item`` receives an instance that has already been destroyed.
    #
    # @example Automatically prefix URLs with http
    #  Zen::Event.listen(:new_menu_item) do |item|
    #    unless item.url =~ /^http/
    #      item.url = 'http://' + item.url
    #      item.save
    #    end
    #  end
    #
    # @author Yorick Peterse
    # @since  0.2a
    # @map    /admin/menu-items
    # @event  before_new_menu_item
    # @event  after_new_menu_item
    # @event  before_edit_menu_item
    # @event  after_edit_menu_item
    # @event  before_delete_menu_item
    # @event  after_delete_menu_item
    #
    class MenuItems <  Zen::Controller::AdminController
      map    '/admin/menu-items'
      helper :menu
      title  'menu_items.titles.%s'

      csrf_protection :save, :delete

      ##
      # Shows an overview of all the menu items for a menu group.
      #
      # @author     Yorick Peterse
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
        @menu_items = search do |query|
          ::Menus::Model::MenuItem.search(query).filter(:menu_id => menu_id)
        end

        @menu_items ||= ::Menus::Model::MenuItem.filter(:menu_id => menu_id)
        @menu_items   = paginate(@menu_items)
      end

      ##
      # Allow the user to create a new menu item for the current menu.
      #
      # @author     Yorick Peterse
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

        @menu_id = menu_id

        if flash[:form_data]
          @menu_item = flash[:form_data]
        else
          @menu_item = ::Menus::Model::MenuItem.new
        end

        render_view(:form)
      end

      ##
      # Allow the user to edit an existing navigation item.
      #
      # @author     Yorick Peterse
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

        @menu_id = menu_id

        if flash[:form_data]
          @menu_item = flash[:form_data]
        else
          @menu_item = validate_menu_item(id, menu_id)
        end

        render_view(:form)
      end

      ##
      # Saves an existing menu iten or creates a new one using the supplied
      # POST data.
      #
      # @author     Yorick Peterse
      # @since      0.2a
      # @permission edit_menu_item (when editing an item)
      # @permission new_menu_item (when creating an item)
      # @event      before_edit_menu_item
      # @event      after_edit_menu_item
      # @event      before_new_menu_item
      # @event      after_new_menu_item
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
          authorize_user!(:edit_menu_item)

          menu_item    = validate_menu_item(post['id'], post['menu_id'])
          save_action  = :save
          before_event = :before_edit_menu_item
          after_event  = :after_edit_menu_item
        else
          authorize_user!(:new_menu_item)

          menu_item    = ::Menus::Model::MenuItem.new
          save_action  = :new
          before_event = :before_new_menu_item
          after_event  = :after_new_menu_item
        end

        post.delete('id')

        # Set our notifications
        success = lang("menu_items.success.#{save_action}")
        error   = lang("menu_items.errors.#{save_action}")

        # Time to save the data
        begin
          post.each { |k, v| menu_item.send("#{k}=", v) }
          Zen::Event.call(before_event, menu_item)

          menu_item.save
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = menu_item
          flash[:form_errors] = menu_item.errors

          redirect_referrer
        end

        Zen::Event.call(after_event, menu_item)

        message(:success, success)
        redirect(MenuItems.r(:edit, menu_item.menu_id, menu_item.id))
      end

      ##
      # Delete all specified menu items based on the values in the POST array
      # "menu_item_ids".
      #
      # @author     Yorick Peterse
      # @since      0.2a
      # @permission delete_menu_item
      # @event      before_delete_menu_item
      # @event      after_delete_menu_item
      #
      def delete
        authorize_user!(:delete_menu_item)

        post = request.subset(:menu_item_ids)

        if !post['menu_item_ids'] or post['menu_item_ids'].empty?
          message(:error, lang('menu_items.errors.no_delete'))
          redirect_referrer
        end

        post['menu_item_ids'].each do |id|
          menu = ::Menus::Model::MenuItem[id]

          next if menu.nil?
          Zen::Event.call(:before_delete_menu_item, menu)

          begin
            menu.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('menu_items.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:after_delete_menu_item, menu)
        end

        message(:success, lang('menu_items.success.delete'))
        redirect_referrer
      end
    end # MenuItems
  end # Controller
end # Menus
