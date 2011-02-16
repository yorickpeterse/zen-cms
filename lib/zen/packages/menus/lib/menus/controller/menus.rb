module Menus
  module Controllers
    ##
    # Controller for managing menu groups. Individual navigation items are managed using
    # the menu items controller, simply named "menu_items".
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class Menus < Zen::Controllers::AdminController
      include ::Menus::Models

      map   '/admin/menus'
      trait :extension_identifier => 'com.zen.menus'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(@zen_general_lang.errors[:csrf], 403)
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
        
        @form_save_url     = Menus.r(:save)
        @form_delete_url   = Menus.r(:delete)
        @menus_lang        = Zen::Language.load('menus')
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @menus_lang.titles.key? method 
            @page_title = @menus_lang.titles[method]
          end
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
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        # Set our breadcrumbs
        set_breadcrumbs(@menus_lang.titles[:index])

        # Get all menus
        @menus = Menu.all
      end
      
      ##
      # Show a form that allows the user to edit the details (such as the name and slug)
      # of a menu group. This method can not be used to manage all menu items for this 
      # group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def edit(id)
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        set_breadcrumbs(
          anchor_to(@menus_lang.titles[:index], Menus.r(:index)), 
          @page_title
        )
        
        if flash[:form_data]
          @menu = flash[:form_data]
        else
          @menu = Menu[id]
        end
      end
      
      ##
      # Show a form that can be used to create a new menu group. Once a menu group has
      # been created users can start adding navigation items to the group.
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
        if !user_authorized?([:create, :read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        # Breadcrumbs, om nom nom!
        set_breadcrumbs(
          anchor_to(@menus_lang.titles[:index], Menus.r(:index)), 
          @page_title
        )

        @menu = Menu.new
      end
      
      ##
      # Saves the changes made to an existing menu group or creates a new group using the
      # supplied POST data. In order to detect this forms that contain data of an existing
      # group should have a hidden field named "id", the value of this field is the primary
      # value of the menu group of which the changes should be saved.
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        # Fetch the POST data and store it in a variable so it's a bit easier to work with
        post = request.params.dup

        # Determine if we're creating a new group or modifying an existing one.
        if !post['id'].empty?
          @menu       = Menu[post['id'].to_i]
          save_action = :save
        else
          @menu       = Menu.new
          save_action = :new
        end

        # Set our notifications
        flash_success = @menus_lang.success[save_action]
        flash_error   = @menus_lang.errors[save_action]

        # Let's see if we can insert/update the data
        begin
          @menu.update(post)
          notification(:success, @menus_lang.titles[:index], flash_success)
        rescue
          notification(:error, @menus_lang.titles[:index], flash_error)

          flash[:form_data]   = @menu
          flash[:form_errors] = @menu.errors
        end

        # Redrect the user to the proper page
        if @menu.id
          redirect(Menus.r(:edit, @menu.id))
        else
          redirect_referrer
        end
      end

      ##
      # Deletes a number of navigation menus based on the supplied primary values.
      # These primary values should be stored in a POST array called "menu_ids".
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.2a
      #      
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        post = request.params.dup

        # We always require a set of IDs
        if !post['menu_ids'] or post['menu_ids'].empty?
          notification(:error, @menus_lang.titles[:index], @menus_lang.errors[:no_delete])
          redirect_referrer
        end

        # Time to delete all menus
        post['menu_ids'].each do |id|
          begin
            Menu[id.to_i].destroy
          rescue
            notification(:error, @menus_lang.titles[:index], @menus_lang.errors[:delete] % id)
            redirect_referrer
          end
        end

        notification(:success, @menus_lang.titles[:index], @menus_lang.success[:delete])
        redirect_referrer
      end
    end
  end
end
