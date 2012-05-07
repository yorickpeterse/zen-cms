##
# Package for managing menus and menu items.
#
# ## Controllers
#
# * {Menus::Controller::Menus}
# * {Menus::Controller::MenuItems}
#
# ## Helpers
#
# * {Ramaze::Helper::Menu}
# * {Ramaze::Helper::MenuFrontend}
#
# ## Models
#
# * {Menus::Model::Menu}
# * {Menus::Model::MenuItem}
#
module Menus
  #:nodoc:
  module Controller
    ##
    # The Menus controller allows you to create custom menu groups. You can
    # create large menu structures without having to write a single line of
    # code. In order to start managing your menus you must first navigate to
    # ``/admin/menus`` (there's a navigation item called "Menus" that you can
    # also use). Once you've reached this page you'll see an overview of all
    # your existing menus or a message telling you that no menus were found (if
    # this is the case). An example of such an overview can be seen in the image
    # below.
    #
    # ![Menus Overview](../../images/menus/menus.png)
    #
    # This overview allows you to edit, create or remove menu groups as well as
    # managing the menu items of a group. Editing a group can be done by
    # clicking the name of the group, creating a new one can be done by clicking
    # the button "Add menu". In both cases you'll end up with the form shown in
    # the image below.
    #
    # ![Edit Menu](../../images/menus/edit_menu.png)
    #
    # In this form you can use the following fields:
    #
    # <table class="table full">
    #     <thead>
    #         <tr>
    #             <th class="field_name">Field</th>
    #             <th>Required</th>
    #             <th>Maximum Length</th>
    #             <th>Description</th>
    #         </tr>
    #     </thead>
    #     <tbody>
    #         <tr>
    #             <td>Name</td>
    #             <td>Yes</td>
    #             <td>255</td>
    #             <td>The name of the menu.</td>
    #         </tr>
    #         <tr>
    #             <td>Slug</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A URL friendly version of the name. If no slug is
    #                 specified one will be generated based on the name.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>HTML class</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A space separated string containing the class(es) to apply
    #                 to the menu. This value should match the pattern
    #                 <code>^[a-zA-Z\-_0-9\s]*$</code>.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>HTML ID</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A single ID to apply to the menu. This value should match
    #                 the pattern <code>^[a-zA-Z\-_0-9]*$</code>.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Description</td>
    #             <td>No</td>
    #             <td>Unlimited</td>
    #             <td>A description of the menu.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # * show\_menu
    # * new\_menu
    # * edit\_menu
    # * delete\_menu
    #
    # @since  0.2a
    # @map    /admin/menus
    #
    class Menus < Zen::Controller::AdminController
      map    '/admin/menus'
      helper :menu
      title  'menus.titles.%s'

      autosave Model::Menu, Model::Menu::COLUMNS, :edit_menu

      csrf_protection :save, :delete

      ##
      # Shows an overview of all existing menus and a few properties of these
      # groups such as the name, slug and the amount of items in that group.
      #
      # @since      0.2a
      # @permission show_menu
      #
      def index
        authorize_user!(:show_menu)

        set_breadcrumbs(lang('menus.titles.index'))

        @menus = search do |query|
          ::Menus::Model::Menu.search(query).order(:id.asc)
        end

        @menus ||= ::Menus::Model::Menu.order(:id.asc)
        @menus   = paginate(@menus)
      end

      ##
      # Show a form that can be used to create a new menu group. Once a menu
      # group has been created users can start adding navigation items to the
      # group.
      #
      # @since      0.2a
      # @permission new_menu
      #
      def new
        authorize_user!(:new_menu)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          @page_title
        )

        @menu = Model::Menu.new
        @menu.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Show a form that allows the user to edit the details (such as the name
      # and slug) of a menu group. This method can not be used to manage all
      # menu items for this group.
      #
      # @since      0.2a
      # @param      [Fixnum] id The ID of the menu to edit.
      # @permission edit_menu
      #
      def edit(id)
        authorize_user!(:edit_menu)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          @page_title
        )

        @menu = validate_menu(id)
        @menu.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves any changes made to an existing menu or creates a new menu.
      #
      # @since      0.2a
      # @permission edit_menu (when editing an existing menu)
      # @permission new_menu (when creating a new menu)
      #
      def save
        post = post_fields(*Model::Menu::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_menu)

          menu        = validate_menu(id)
          save_action = :save
        else
          authorize_user!(:new_menu)

          menu        = ::Menus::Model::Menu.new
          save_action = :new
        end

        success = lang("menus.success.#{save_action}")
        error   = lang("menus.errors.#{save_action}")

        begin
          menu.set(post)
          menu.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
          flash[:form_errors] = menu.errors

          redirect_referrer
        end

        message(:success, success)
        redirect(Menus.r(:edit, menu.id))
      end

      ##
      # Deletes a number of navigation menus based on the supplied primary
      # values. These primary values should be stored in a POST array called
      # "menu_ids".
      #
      # @since      0.2a
      # @permission delete_menu
      #
      def delete
        authorize_user!(:delete_menu)

        post = request.params.dup

        if !post['menu_ids'] or post['menu_ids'].empty?
          message(:error, lang('menus.errors.no_delete'))
          redirect_referrer
        end

        # Time to delete all menus
        post['menu_ids'].each do |id|
          menu = ::Menus::Model::Menu[id]

          next if menu.nil?

          begin
            menu.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('menus.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('menus.success.delete'))
        redirect_referrer
      end
    end # Menus
  end # Controller
end # Menus
