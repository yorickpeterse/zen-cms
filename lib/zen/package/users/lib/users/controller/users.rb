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
    # ![Users](../../images/users/overview.png)
    #
    # This overview allows you to edit users (by clicking on their Email
    # addresses), create new ones or delete existing users. When editing or
    # creating a user you'll be presented a form as shown in the images below.
    #
    # ![Edit User](../../images/users/edit_user.png)
    # ![Edit Permissions](../../images/users/edit_user_permissions.png)
    #
    # In this form the following fields can be filled:
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
    #             <td>The full name of the user.</td>
    #         </tr>
    #         <tr>
    #             <td>Email</td>
    #             <td>Yes</td>
    #             <td>255</td>
    #             <td>The Email address of the user.</td>
    #         </tr>
    #         <tr>
    #             <td>Website</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>The website of the user.</td>
    #         </tr>
    #         <tr>
    #             <td>Password</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>The password for the user.</td>
    #         </tr>
    #         <tr>
    #             <td>Confirm Password</td>
    #             <td>
    #                 Only when a password has been specified in the "Password"
    #                 field.
    #             </td>
    #             <td>255</td>
    #             <td>
    #                 Field used to confirm the password in case of setting a
    #                 new one.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Status</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>The status of the user, set to closed by default.</td>
    #         </tr>
    #         <tr>
    #             <td>User groups</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>A selection of groups to add the user to.</td>
    #         </tr>
    #         <tr>
    #             <td>Language</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>The language to use for the backend of the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Frontend Language</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>The language to use for the frontend of the website.</td>
    #         </tr>
    #         <tr>
    #             <td>Date format</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>The date format to use for the backend.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # Besides these fields there's also the tab "Permissions". This tab contains
    # a collection of all installed packages and their permissions. This makes
    # it possible to fine tune the access of a certain user.
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show\_user
    # * new\_user
    # * edit\_user
    # * delete\_user
    #
    # @since  0.1
    # @map    /admin/users
    # @event  user\_login
    # @event  before\_register\_user
    # @event  after\_register\_user
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
          Model::User.search(query).order(:id.asc)
        end

        @users ||= Model::User.order(:id.asc)
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

        @user = validate_user(id)
        @user.set(flash[:form_data]) if flash[:form_data]

        @user_group_pks = Model::UserGroup.pk_hash(:name).invert
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

        @user           = Model::User.new
        @user_group_pks = Model::UserGroup.pk_hash(:name).invert

        @user.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Show a form that allows a user to log in.
      #
      # @since  0.1
      # @event  user\_login
      #
      def login
        if request.post?
          # Let's see if we can authenticate
          if user_login(post_fields(:email, :password))
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
      # @event before\_register\_user
      # @event after\_register\_user
      #
      def register
        redirect(Dashboard::Controller::Dashboard.r(:index)) if logged_in?
        redirect(r(:login)) unless get_setting(:allow_registration).true?

        if request.post?
          post = post_fields(:name, :email, :password)
          user = Model::User.new(post)

          # Check if the passwords match.
          if post['password'] != request.params['confirm_password']
            post.delete('password')
            flash[:form_data] = post

            message(:error, lang('users.errors.no_password_match'))
            redirect(r(:register))
          end

          Zen::Event.call(:before_register_user, user, post['password'])

          begin
            user.save
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('users.errors.register'))

            post.delete('password')

            flash[:form_errors] = user.errors
            flash[:form_data]   = post

            redirect(r(:register))
          end

          Zen::Event.call(:after_register_user, user, post['password'])
          message(:success, lang('users.success.register'))

          redirect(r(:login))
        end

        @user = Model::User.new
        @uset.set(flash[:form_data]) if flash[:form_data]
      end

      ##
      # Saves or creates a new user based on the POST data.
      #
      # @since      0.1
      # @permission new_user (when creating a new user)
      # @permission edit_user (when editing a user)
      #
      def save
        post = post_fields(*Model::User::COLUMNS)
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

          flash[:form_data]   = post
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
          user = Model::User[id]

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
