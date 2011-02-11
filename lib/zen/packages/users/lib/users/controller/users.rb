module Users
  module Controllers
    ##
    # Controller for managing users. Users in this case are people
    # that have access to the backend. However, users might be able
    # to access the backend but that doesn't mean they can actuall use it.
    # The permission system will block anybody that don't have the correct
    # permissions for each module. In case of a module like a forum it's
    # probably better to add some additional checks to ensure people
    # can't mess around with your system.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Users < Zen::Controllers::AdminController
      map '/admin/users'
      
      trait :extension_identifier => 'com.zen.users'
      include ::Users::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 403)
        end
      end
      
      # Every action should use the admin layout except the "login" method,
      # that one will use a trimmed down version of the admin layout.
      layout do |path, format|
        if path == 'login'
          :login
        else
          :admin
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
        
        @form_save_url   = '/admin/users/save'
        @form_delete_url = '/admin/users/delete'
        @form_login_url  = '/admin/users/login'
        @users_lang      = Zen::Language.load 'users'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @users_lang.titles.key? method 
            @page_title = @users_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all users and allow the current user
      # to manage these users.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @users_lang.titles[:index]
        
        @users = User.all
      end
      
      ##
      # Edit an existing user based on the ID.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@users_lang.titles[:index], "admin/users"), @users_lang.titles[:edit]
        
        @user           = User[id]
        @user_group_pks = UserGroup.pk_hash(:name)
      end
      
      ##
      # Create a new user.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@users_lang.titles[:index], "admin/users"), @users_lang.titles[:new]
        
        @user           = User.new
        @user_group_pks = UserGroup.pk_hash(:name)
      end
      
      ##
      # Show a form that allows a user to log in.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def login
        if request.post?
          # Let's see if we can authenticate
          if user_login(request.subset(:email, :password))
            # Update the last time the user logged in
            User[:email => request.params['email']].update(:last_login => Time.new)
            
            notification :success, @users_lang.titles[:index], @users_lang.success[:login]
            redirect "admin"
          else
            notification :error, @users_lang.titles[:index], @users_lang.errors[:login]
          end
        end
      end
      
      ##
      # Logout and destroy the user's session.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def logout
        user_logout
        
        notification :success, @users_lang.titles[:index], @users_lang.success[:logout]
        redirect "admin/users/login"
      end
      
      ##
      # Saves or creates a new user based on the POST data and a field named "id".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:update, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
       
        if post["id"] and !post["id"].empty?
          @user       = User[post["id"]]
          save_action = :save
        else
          @user       = User.new
          save_action = :new
        end
        
        if !post['new_password'].nil? and !post['new_password'].empty?
          if post['new_password'] != post['confirm_password']
            notification :error, @users_lang.titles[:index], @users_lang.errors[:no_password_match]
            redirect_referrer
          else
            post['password'] = post['new_password']
            
            post.delete 'new_password'
            post.delete 'confirm_password'
          end
        end
        
        # User group pks have to be integers
        if !post["user_group_pks"].nil?
          post["user_group_pks"].map! { |value| value.to_i }
        else
          post["user_group_pks"] = []
        end
        
        flash_success = @users_lang.success[save_action]
        flash_error   = @users_lang.errors[save_action]

        begin
          @user.update(post)
          notification(:success, @users_lang.titles[:index], flash_success)
        rescue
          notification(:error, @users_lang.titles[:index], flash_error)
          
          flash[:form_errors] = @user.errors
        end
        
        if @user.id
          redirect "/admin/users/edit/#{@user.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete all specified users.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["user_ids"] or request.params["user_ids"].empty?
          notification(:error, @users_lang.titles[:index], @users_lang.errors[:no_delete])
          redirect_referrer
        end
        
        request.params["user_ids"].each do |id|
          @user = User[id]
          
          begin
            @user.delete
            notification(:success, @users_lang.titles[:index], @users_lang.success[:delete] % id)
          rescue
            notification(:error, @users_lang.titles[:index], @users_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end
  end
end
