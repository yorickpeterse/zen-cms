module Users
  #:nodoc:
  module Controller
    ##
    # User groups allow you to group types of users together and assign
    # permissions to the entire group of users without having to modify each
    # individual user.
    #
    # User groups can be managed by going to ``/admin/user-groups``. This page
    # will show an overview of all existing groups or a message saying no groups
    # have been added yet.
    #
    # ![User Groups](../../_static/users/user_groups_overview.png)
    #
    # Editing a user group can be done by clicking on the name of the group,
    # creating a new one can be done by clicking the button "New group". When
    # creating or editing a group you'll be presented with the form shown in the
    # images below.
    #
    # ![Edit Group](../../_static/users/edit_user_group.png)
    # ![Group Permissions](../../_static/users/edit_user_group_permissions.png)
    #
    # In this form you can fill in the following fields:
    #
    # * **Name** (required): the name of the user group.
    # * **Slug**: a URL friendly version of the name. If no name is specified
    #   one will be generated automatically.
    # * **Super group** (required): when set to "Yes" all users that are
    #   assigned to this group will have access to *everything* regardless of
    #   their individual settings.
    # * **Description**: a description of the user group.
    #
    # Besides these fields you can also specify all the permissions o the user
    # group similar to how they're managed for individual users. Note that user
    # specific rules will only overwrite group based rules if a group blocks
    # something while a user specific rules allows something. Simply said, rules
    # are added to the list but aren't removed based on their source.
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_user_group
    # * edit_user_group
    # * new_user_group
    # * delete_user_group
    #
    # ## Events
    #
    # All events in this controller receive an instance of
    # {Users::Model::UserGroup}. Just like other controllers the event
    # ``delete_user_group`` will receive a user group that has already been
    # destroyed using ``#destroy()``.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/user-groups
    # @event  new_user_group
    # @event  edit_user_group
    # @event  delete_user_group
    #
    class UserGroups < Zen::Controller::AdminController
      helper :users
      map    '/admin/user-groups'
      title  'user_groups.titles.%s'

      csrf_protection  :save, :delete
      load_asset_group :tabs

      serve :javascript, ['/admin/js/users/permissions'], :minify => false
      serve :css, ['/admin/css/users/permissions.css'], :minify => false

      # Hook that is executed before UserGroups#index(), UserGroups#edit() and
      # UserGroups#new().
      before(:index, :edit, :new) do
        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }
      end

      ##
      # Show an overview of all user groups and allow the current user
      # to manage these groups
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_user_group
      #
      def index
        authorize_user!(:show_user_group)

        set_breadcrumbs(lang('user_groups.titles.index'))

        @user_groups = paginate(::Users::Model::UserGroup)
      end

      ##
      # Edit an existing user group.
      #
      # @author     Yorick Peterse
      # @param      [Fixnum] id The ID of the user group to edit.
      # @since      0.1
      # @permission edit_user_group
      #
      def edit(id)
        authorize_user!(:edit_user_group)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.edit')
        )

        @user_group  = flash[:form_data] || validate_user_group(id)
        @permissions = @user_group.permissions.map { |p| p.permission.to_sym }

        render_view(:form)
      end

      ##
      # Create a new user group.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission new_user_group
      #
      def new
        authorize_user!(:new_user_group)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.new')
        )

        @user_group = flash[:form_data] || ::Users::Model::UserGroup.new

        render_view(:form)
      end

      ##
      # Saves or creates a new user group based on the POST data and a field
      # named 'id'.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission new_user_group (when creating a new group)
      # @permission edit_user_group (when editing a group)
      # @event      new_user_group
      # @event      edit_user_group
      #
      def save
        post = request.subset(:id, :name, :slug, :description, :super_group)

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_user_group)

          user_group  = validate_user_group(post['id'])
          save_action = :save
          event       = :edit_user_group
        else
          authorize_user!(:new_user_group)

          user_group  = ::Users::Model::UserGroup.new
          save_action = :new
          event       = :new_user_group
        end

        post.delete('id')

        success = lang("user_groups.success.#{save_action}")
        error   = lang("user_groups.errors.#{save_action}")

        begin
          user_group.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = user_group
          flash[:form_errors] = user_group.errors

          redirect_referrer
        end

        if user_authorized?(:edit_permission)
          update_permissions(
            :user_group_id,
            user_group.id,
            request.params['permissions'] || [],
            user_group.permissions.map { |p| p.permission }
          )
        end

        Zen::Event.call(event, user_group)

        message(:success, success)
        redirect(UserGroups.r(:edit, user_group.id))
      end

      ##
      # Deletes all specified user groups.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission delete_user_group
      # @event      delete_user_group
      #
      def delete
        authorize_user!(:delete_user_group)

        if !request.params['user_group_ids'] \
        or request.params['user_group_ids'].empty?
          message(:error, lang('user_groups.errors.no_delete'))
          redirect_referrer
        end

        request.params['user_group_ids'].each do |id|
          group = ::Users::Model::UserGroup[id]

          next if group.nil?

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('user_groups.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_user_group, group)
        end

        message(:success,  lang('user_groups.success.delete'))
        redirect_referrer
      end
    end # UserGroups
  end # Controller
end # Users
