#:nodoc:
module Menus
  #:nodoc:
  module Controller
    ##
    # Controller for managing menu groups..
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class Menus < Zen::Controller::AdminController
      include ::Menus::Model

      map '/admin/menus'
      helper :menu

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Initializes the class and loads all required language packs.
      #
      # This method loads the following language files:
      #
      # * menus
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def initialize
        super

        Zen::Language.load('menus')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("menus.titles.#{method}") rescue nil
        end
      end

      ##
      # Shows an overview of all exisitng menus and a few properties of these
      # groups such as the name, slug and the amount of items in that group.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def index
        require_permissions(:read)

        set_breadcrumbs(lang('menus.titles.index'))

        @menus = paginate(Menu)
      end

      ##
      # Show a form that allows the user to edit the details (such as the name
      # and slug) of a menu group. This method can not be used to manage all
      # menu items for this group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Fixnum] id The ID of the menu to edit.
      #
      def edit(id)
        require_permissions(:read, :update)

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
        require_permissions(:create, :read)

        set_breadcrumbs(
          Menus.a(lang('menus.titles.index'), :index),
          @page_title
        )

        @menu = Menu.new

        render_view(:form)
      end

      ##
      # Saves the changes made to an existing menu group or creates a new group
      # using the supplied POST data. In order to detect this forms that contain
      # data of an existing group should have a hidden field named "id", the
      # value of this field is the primary value of the menu group of which the
      # changes should be saved.
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
          :name,
          :slug,
          :description,
          :html_class,
          :html_id,
          :id
        )

        # Determine if we're creating a new group or modifying an existing one.
        if post.key?('id') and !post['id'].empty?
          require_permissions(:update)

          @menu       = validate_menu(post['id'])
          save_action = :save
        else
          require_permissions(:create)

          @menu       = Menu.new
          save_action = :new

          # Delete the slug if it's empty
          post.delete('slug') if post['slug'].empty?
        end

        post.delete('id')

        flash_success = lang("menus.success.#{save_action}")
        flash_error   = lang("menus.errors.#{save_action}")

        # Let's see if we can insert/update the data
        begin
          @menu.update(post)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = @menu
          flash[:form_errors] = @menu.errors

          redirect_referrer
        end

        # Redrect the user to the proper page
        if @menu.id
          redirect(Menus.r(:edit, @menu.id))
        else
          redirect_referrer
        end
      end

      ##
      # Deletes a number of navigation menus based on the supplied primary
      # values. These primary values should be stored in a POST array called
      # "menu_ids".
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def delete
        require_permissions(:delete)

        post = request.params.dup

        # We always require a set of IDs
        if !post['menu_ids'] or post['menu_ids'].empty?
          message(:error, lang('menus.errors.no_delete'))
          redirect_referrer
        end

        # Time to delete all menus
        post['menu_ids'].each do |id|
          begin
            Menu[id].destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
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
