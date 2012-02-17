##
# Package for managing users, user groups and the permissions of users and user
# groups.
#
# ## Controllers
#
# * {Users::Controller::Users}
# * {Users::Controller::UserGroups}
#
# ## Helpers
#
# * {Ramaze::Helper::Users}
# * {Ramaze::Helper::ACL}
#
# ## Models
#
# * {Users::Model::User}
# * {Users::Model::UserGroup}
# * {Users::Model::Permission}
#
module Users
  #:nodoc:
  module Controller
    ##
    # Zen makes it easy for users to manage their own account as well as other
    # users depending on their permissions. In Zen there's no special type of
    # user such as an administrator or a contributor, instead users have access
    # to various parts of your websites based on their permissions and the
    # groups they have been assigned to (see {Users::Controller::UserGroups
    # Managing User Groups} for more information).
    #
    # Users can be managed in the admin interface by going to ``/admin/users``.
    # Just like other parts of the application you may not be able to manage
    # users (or only partially) depending on your permissions.
    #
    # When navigating to the user overview (assuming you have the correct
    # permissions) you should see a page that looks like the one shown in the
    # image below.
    #
    # ![Users](../../_static/users/overview.png)
    #
    # This overview allows you to edit users (by clicking on their Email
    # addresses), create new ones or delete existing users. When editing or
    # creating a user you'll be presented a form as shown in the images below.
    #
    # ![Edit User](../../_static/users/edit_user.png)
    # ![Edit Permissions](../../_static/users/edit_user_permissions.png)
    #
    # In this form the following fields can be filled:
    #
    # * **Name** (required): the full name of the user.
    # * **Email** (required): the Email address of the user, used for logging
    #   in.
    # * **Website**: the website of the user (if he/she has any).
    # * **Password** (required for new users): the raw password the user will
    #   use in order to log in.
    # * **Confirm password** (required for new users): an extra field to confirm
    #   that the specified password is the right one. This field should match
    #   the password specified in the "Password" field.
    # * **Status**: field that indicates if a user is active or not. If the
    #   status is set to "Closed" the user will not be able to log in.
    # * **User Groups**: all the user groups the user belongs to.
    # * **Language**: the language to use for the admin interface.
    # * **Frontend language**: the language to use for the frontend of the
    #   application.
    # * **Date format**: the date format to use in the admin interface.
    #
    # Besides these fields there's also the tab "Permissions". This tab contains
    # a collection of all installed packages and their permissions. This makes
    # it possible to fine tune the access of a certain user.
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_user
    # * new_user
    # * edit_user
    # * delete_user
    #
    # @since  0.1
    # @map    /admin/users
    # @event  user_login
    # @event  before_register_user
    # @event  after_register_user
    #
    class Users < Zen::Controller::AdminController
      helper :users, :layout
      map    '/admin/users'
      title  'users.titles.%s'
      allow  [:login, :logout, :register]

      autosave Model::User, Model::User::COLUMNS, :edit_user

      csrf_protection  :save, :delete
      load_asset_group :tabs

      serve :javascript, ['/admin/users/js/users'], :name => 'users'
      serve :css, ['/admin/users/css/users.css'], :name => 'users'

      set_layout :admin => [:index, :edit, :new],
        :login => [:login, :register]

      ##
      # Show an overview of all users and allow the current user
      # to manage these users.
      #
      # @since      0.1
      # @permission show_user
      #
      def index
        authorize_user!(:show_user)

        set_breadcrumbs(lang('users.titles.index'))

        @users = search do |query|
          ::Users::Model::User.search(query).order(:id.asc)
        end

        @users ||= ::Users::Model::User.order(:id.asc)
        @users   = @users.eager(:user_status)
        @users   = paginate(@users)
      end

      ##
      # Edit an existing user based on the ID.
      #
      # @param      [Fixnum] id The ID of the user to edit.
      # @since      0.1
      # @permission edit_user
      #
      def edit(id)
        authorize_user!(:edit_user) unless user.id == id.to_i

        set_breadcrumbs(
          Users.a(lang('users.titles.index'), :index),
          lang('users.titles.edit')
        )

        @user           = flash[:form_data] || validate_user(id)
        @user_group_pks = ::Users::Model::UserGroup.pk_hash(:name).invert
        @permissions    = @user.permissions.map { |p| p.permission.to_sym }

        render_view(:form)
      end

      ##
      # Create a new user.
      #
      # @since      0.1
      # @permission new_user
      #
      def new
        authorize_user!(:new_user)

        set_breadcrumbs(
          Users.a(lang('users.titles.index'), :index),
          lang('users.titles.new')
        )

        @user           = flash[:form_data] || ::Users::Model::User.new
        @user_group_pks = ::Users::Model::UserGroup.pk_hash(:name).invert

        render_view(:form)
      end

      ##
      # Show a form that allows a user to log in.
      #
      # @since  0.1
      # @event  user_login
      #
      def login
        if request.post?
          # Let's see if we can authenticate
          if user_login(request.subset(:email, :password))
            user.update(:last_login => Time.new)

            Zen::Event.call(:user_login, user)
            message(:success, lang('users.success.login'))
            redirect(Dashboard::Controller::Dashboard.r(:index))
          else
            message(:error, lang('users.errors.login'))
          end

          redirect(r(:login))
        end
      end

      ##
      # Logout and destroy the user's session.
      #
      # @since  0.1
      #
      def logout
        user_logout
        session.clear

        message(:success, lang('users.success.logout'))
        redirect(r(:login))
      end

      ##
      # Allows non registered users to create an account as long as the setting
      # "allow_registration" allows this. In case of errors this method will
      # redirect to itself, this works around those rather annoying "Do you want
      # to resubmit this form?" messages most browsers give you.
      #
      # The events ``before_register_user`` and ``after_register_user`` will
      # receive an instance of {Users::Model::User} as well as the raw password
      # specified by the user.
      #
      # @since 0.3
      # @event before_register_user
      # @event after_register_user
      #
      def register
        redirect(Dashboard::Controller::Dashboard.r(:index)) if logged_in?
        redirect(r(:login)) unless get_setting(:allow_registration).true?

        if request.post?
          post = request.subset(:name, :email, :password)
          user = Model::User.new(post)

          # Check if the passwords match.
          if post['password'] != request.params['confirm_password']
            flash[:form_data] = user

            message(:error, lang('users.errors.no_password_match'))
            redirect(r(:register))
          end

          Zen::Event.call(:before_register_user, user, post['password'])

          begin
            user.save
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('users.errors.register'))

            flash[:form_errors] = user.errors
            flash[:form_data]   = user

            redirect(r(:register))
          end

          Zen::Event.call(:after_register_user, user, post['password'])
          message(:success, lang('users.success.register'))

          redirect(r(:login))
        end

        @user = flash[:form_data] || Model::User.new
      end

      ##
      # Saves or creates a new user based on the POST data.
      #
      # @since      0.1
      # @permission new_user (when creating a new user)
      # @permission edit_user (when editing a user)
      #
      def save
        post = request.subset(*Model::User::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_user) unless id.to_i == user.id

          user        = validate_user(id)
          save_action = :save
        else
          authorize_user!(:new_user)

          user        = Model::User.new
          save_action = :new
        end

        if post['password'] != post['confirm_password']
          message(:error, lang('users.errors.no_password_match'))
          redirect_referrer
        end

        post.delete('confirm_password')

        post['user_group_pks'] ||= []
        success                  = lang("users.success.#{save_action}")
        error                    = lang("users.errors.#{save_action}")

        unless user_authorized?(:assign_user_group)
          post.delete('user_group_pks')
        end

        unless user_authorized?(:edit_user_status)
          post.delete('user_status_id')
        end

        begin
          post.each { |k, v| user.send("#{k}=", v) }

          user.save

          if save_action == :new and post['user_group_pks']
            user.user_group_pks = post['user_group_pks']
          end
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = user
          flash[:form_errors] = user.errors

          redirect_referrer
        end

        # Add or update the permissions if the user is allowed to do so.
        if user_authorized?(:edit_permission)
          update_permissions(
            :user_id,
            user.id,
            request.params['permissions'] || [],
            user.permissions.map { |p| p.permission }
          )
        end

        message(:success, success)
        redirect(Users.r(:edit, user.id))
      end

      ##
      # Delete all specified users.
      #
      # @since      0.1
      # @permission delete_user
      #
      def delete
        authorize_user!(:delete_user)

        if !request.params['user_ids'] or request.params['user_ids'].empty?
          message(:error, lang('users.errors.no_delete'))
          redirect_referrer
        end

        request.params['user_ids'].each do |id|
          user = ::Users::Model::User[id]

          next if user.nil?

          begin
            user.user_group_pks = []
            user.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('users.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('users.success.delete'))
        redirect_referrer
      end
    end # Users
  end # Controller
end # Users
