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
#
# ## Models
#
# * {Menus::Model::Menu}
# * {Menus::Model::MenuItem}
#
# ## Plugins
#
# * {Menus::Plugin::Menus}
#
module Menus
  #:nodoc:
  module Controller
    ##
    # Controller for managing menu groups.
    #
    # ## Used Permissions
    #
    # * show_menu
    # * new_menu
    # * edit_menu
    # * delete_menu
    #
    # ## Available Events
    #
    # * new_menu
    # * edit_menu
    # * delete_menu
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class Menus < Zen::Controller::AdminController
      map    '/admin/menus'
      helper :menu
      title  'menus.titles.%s'

      csrf_protection :save, :delete

      ##
      # Shows an overview of all exisitng menus and a few properties of these
      # groups such as the name, slug and the amount of items in that group.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def index
        authorize_user!(:show_menu)

        set_breadcrumbs(lang('menus.titles.index'))

        @menus = paginate(::Menus::Model::Menu)
      end

      ##
      # Show a form that can be used to create a new menu group. Once a menu
      # group has been created users can start adding navigation items to the
      # group.
      #
      # This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def new
        authorize_user!(:new_menu)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          @page_title
        )

        @menu = ::Menus::Model::Menu.new

        render_view(:form)
      end

      ##
      # Show a form that allows the user to edit the details (such as the name
      # and slug) of a menu group. This method can not be used to manage all
      # menu items for this group.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Fixnum] id The ID of the menu to edit.
      #
      def edit(id)
        authorize_user!(:edit_menu)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          @page_title
        )

        if flash[:form_data]
          @menu = flash[:form_data]
        else
          @menu = validate_menu(id)
        end

        render_view(:form)
      end

      ##
      # Saves the changes made to an existing menu group or creates a new group
      # using the supplied POST data. In order to detect this forms that contain
      # data of an existing group should have a hidden field named "id", the
      # value of this field is the primary value of the menu group of which the
      # changes should be saved.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def save
        post = request.subset(
          :name,
          :slug,
          :description,
          :html_class,
          :html_id,
          :id
        )

        # Determine if we're creating a new group or modifying an existing one.
        if post.key?('id') and !post['id'].empty?
          authorize_user!(:edit_menu)

          menu        = validate_menu(post['id'])
          save_action = :save
          event       = :edit_menu
        else
          authorize_user!(:new_menu)

          menu        = ::Menus::Model::Menu.new
          save_action = :new
          event       = :new_menu
        end

        post.delete('id')

        success = lang("menus.success.#{save_action}")
        error   = lang("menus.errors.#{save_action}")

        # Let's see if we can insert/update the data
        begin
          menu.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = menu
          flash[:form_errors] = menu.errors

          redirect_referrer
        end

        Zen::Event.call(event, menu)

        message(:success, success)
        redirect(Menus.r(:edit, menu.id))
      end

      ##
      # Deletes a number of navigation menus based on the supplied primary
      # values. These primary values should be stored in a POST array called
      # "menu_ids".
      #
      # @author Yorick Peterse
      # @since  0.2a
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
            Ramaze::Log.error(e.inspect)
            message(:error, lang('menus.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_menu, menu)
        end

        message(:success, lang('menus.success.delete'))
        redirect_referrer
      end
    end # Menus
  end # Controller
end # Menus
