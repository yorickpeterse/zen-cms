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
    # * **Status** (required): field that indicates if a user is active or not.
    #   If the status is set to "Closed" the user will not be able to log in.
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
    # ## Events
    #
    # Events in this controller receive an instance of {Users::Model::User}, the
    # ``delete_user`` event receives an instance that has already been
    # destroyed. Keep in mind that changing the Email address or password of a
    # user will cause their session to no longer be valid, requiring them to log
    # in again.
    #
    # @example Sending an Email for a new user
    #  Zen::Event.listen(:new_user) do |user|
    #    Mail.deliver do
    #      from    'user@domain.tld'
    #      to      user.email
    #      subject 'Your new account'
    #      body    "Dear #{user.name}, your account has been created."
    #    end
    #  end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/users
    # @event  new_user
    # @event  edit_user
    # @event  delete_user
    #
    class Users < Zen::Controller::AdminController
      helper :users, :layout
      map    '/admin/users'
      title  'users.titles.%s'

      csrf_protection :save, :delete

      serve :javascript, ['/admin/js/users/permissions'], :minify => false
      serve :css, ['/admin/css/users/permissions.css'], :minify => false

      load_asset_group :tabs

      set_layout :admin => [:index, :edit, :new]
      set_layout :login => [:login]

      # Hook that's executed before Users#index(), Users#edit() and Users#new().
      before(:index, :edit, :new) do
        @status_hash = {
          'open'   => lang('users.special.status_hash.open'),
          'closed' => lang('users.special.status_hash.closed')
        }
      end

      ##
      # Show an overview of all users and allow the current user
      # to manage these users.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_user
      #
      def index
        authorize_user!(:show_user)

        set_breadcrumbs(lang('users.titles.index'))

        @users = paginate(::Users::Model::User)
      end

      ##
      # Edit an existing user based on the ID.
      #
      # @author     Yorick Peterse
      # @param      [Fixnum] id The ID of the user to edit.
      # @since      0.1
      # @permission edit_user
      #
      def edit(id)
        authorize_user!(:edit_user)

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
      # @author     Yorick Peterse
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def login
        if request.post?
          # Let's see if we can authenticate
          if user_login(request.subset(:email, :password))
            user.update(:last_login => Time.new)

            message(:success, lang('users.success.login'))
            redirect(::Sections::Controller::Sections.r(:index))
          else
            message(:error, lang('users.errors.login'))
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
        session.clear

        message(:success, lang('users.success.logout'))
        redirect(Users.r(:login))
      end

      ##
      # Saves or creates a new user based on the POST data.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission new_user (when creating a new user)
      # @permission edit_user (when editing a user)
      # @event      new_user
      # @event      edit_user
      #
      def save
        post = request.subset(
          :id,
          :email,
          :name,
          :website,
          :password,
          :confirm_password,
          :status,
          :language,
          :frontend_language,
          :date_format,
          :user_group_pks
        )

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_user)

          user        = validate_user(post['id'])
          save_action = :save
          event       = :edit_user
        else
          authorize_user!(:new_user)

          user        = ::Users::Model::User.new
          save_action = :new
          event       = :new_user
        end

        if post['password'] != post['confirm_password']
          message(:error, lang('users.errors.no_password_match'))
          redirect_referrer
        end

        post.delete('confirm_password')
        post.delete('id')

        post['user_group_pks'] ||= []
        success            = lang("users.success.#{save_action}")
        error              = lang("users.errors.#{save_action}")

        begin
          user.update(post)
          user.user_group_pks = post['user_group_pks'] if save_action === :new
        rescue => e
          Ramaze::Log.error(e.inspect)
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

        Zen::Event.call(event, user)

        message(:success, success)
        redirect(Users.r(:edit, user.id))
      end

      ##
      # Delete all specified users.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission delete_user
      # @event      delete_user
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
            Ramaze::Log.error(e.inspect)
            message(:error, lang('users.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_user, user)
        end

        message(:success, lang('users.success.delete'))
        redirect_referrer
      end
    end # Users
  end # Controller
end # Users
