module Users
  module Controllers
    ##
    # Controller for managing all user groups. It's not
    # required to add a user to a group but it can certainly
    # make it easier when adding custom permissions or
    # granting a user full access to the backend.
    # 
    # @author Yorick Peterse
    # @since  0.1
    #
    class UserGroups < Zen::Controllers::AdminController
      map '/admin/user_groups'
      
      trait :extension_identifier => 'com.yorickpeterse.users'
      include ::Users::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 401)
        end
      end
      
      ##
      # Load our language packs, set the form URLs and define our page title.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = '/admin/user_groups/save'
        @form_delete_url = '/admin/user_groups/delete'
        @groups_lang     = Zen::Language.load 'user_groups'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @groups_lang.titles.key? method 
            @page_title = @groups_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all user groups and allow the current user
      # to manage these groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @groups_lang.titles[:index]
        
        @user_groups = UserGroup.all
      end
      
      ##
      # Edit an existing user group
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/user_groups"), @groups_lang.titles[:edit]
        
        @user_group = UserGroup[id]
      end
      
      ##
      # Create a new user group
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/user_groups"), @groups_lang.titles[:new]
        
        @user_group = UserGroup.new
      end
      
      ##
      # Saves or creates a new user group based on the POST data and a field named "id".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
       
        post.each do |key, value|
          post.delete(key) if value.empty?
        end

        if post["id"] and !post["id"].empty?
          @user_group = UserGroup[post["id"]]
          save_action = :save
        else
          @user_group = UserGroup.new
          save_action = :new
        end
        
        flash_success = @groups_lang.success[save_action]
        flash_error   = @groups_lang.errors[save_action]
        
        begin
          @user_group.update(post)
          notification(:success, @groups_lang.titles[:index], flash_success)
        rescue
          notification(:error, @groups_lang.titles[:index], flash_error)
          
          flash[:form_errors] = @user.errors
        end
        
        if @user_group.id
          redirect "/admin/user_groups/edit/#{@user_group.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete all specified user groups.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["user_group_ids"] or request.params["user_group_ids"].empty?
          notification(:error, @groups_lang.titles[:index], @groups_lang.errors[:no_delete])
          redirect_referrer
        end
        
        request.params["user_group_ids"].each do |id|
          @user_group = UserGroup[id]
          
          begin
            @user_group.delete
            notification(:success, @groups_lang.titles[:index], @groups_lang.success[:delete] % id)
          rescue
            notification(:error, @groups_lang.titles[:index], @groups_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end
  end
end
