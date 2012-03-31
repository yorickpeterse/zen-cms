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
    # ![User Groups](../../images/users/user_groups_overview.png)
    #
    # Editing a user group can be done by clicking on the name of the group,
    # creating a new one can be done by clicking the button "New group". When
    # creating or editing a group you'll be presented with the form shown in the
    # images below.
    #
    # ![Edit Group](../../images/users/edit_user_group.png)
    # ![Group Permissions](../../images/users/edit_user_group_permissions.png)
    #
    # In this form you can fill in the following fields:
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
    #             <td>The name of the user group.</td>
    #         </tr>
    #         <tr>
    #             <td>Slug</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A URL friendly version of the user group. If no value is
    #                 specified one will be generated automatically based on the name
    #                 of the user group.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Super group</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>
    #                 When set users of this group have full access to the backend.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Description</td>
    #             <td>No</td>
    #             <td>Unlimited</td>
    #             <td>A description of the user group.</td>
    #         </tr>
    #     </tbody>
    # </table>
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
    # @since  0.1
    # @map    /admin/user-groups
    #
    class UserGroups < Zen::Controller::AdminController
      helper :users
      map    '/admin/user-groups'
      title  'user_groups.titles.%s'

      autosave Model::UserGroup, Model::UserGroup::COLUMNS, :edit_user_group

      csrf_protection  :save, :delete
      load_asset_group :tabs

      serve :javascript, ['/admin/users/js/users'], :name => 'users'
      serve :css, ['/admin/users/css/users.css'], :name => 'users'

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
      # @since      0.1
      # @permission show_user_group
      #
      def index
        authorize_user!(:show_user_group)

        set_breadcrumbs(lang('user_groups.titles.index'))

        @user_groups = search do |query|
          ::Users::Model::UserGroup.search(query).order(:id.asc)
        end

        @user_groups ||= ::Users::Model::UserGroup.order(:id.asc)
        @user_groups   = paginate(@user_groups)
      end

      ##
      # Edit an existing user group.
      #
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

        @user_group  = validate_user_group(id)
        @user_group.set(flash[:form_data]) if flash[:form_data]
        @permissions = @user_group.permissions.map { |p| p.permission.to_sym }

        render_view(:form)
      end

      ##
      # Create a new user group.
      #
      # @since      0.1
      # @permission new_user_group
      #
      def new
        authorize_user!(:new_user_group)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.new')
        )

        @user_group = Model::UserGroup.new
        @user_group.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves or creates a new user group based on the POST data and a field
      # named 'id'.
      #
      # @since      0.1
      # @permission new_user_group (when creating a new group)
      # @permission edit_user_group (when editing a group)
      #
      def save
        post = post_fields(*Model::UserGroup::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_user_group)

          user_group  = validate_user_group(id)
          save_action = :save
        else
          authorize_user!(:new_user_group)

          user_group  = Model::UserGroup.new
          save_action = :new
        end

        success = lang("user_groups.success.#{save_action}")
        error   = lang("user_groups.errors.#{save_action}")

        begin
          user_group.set(post)
          user_group.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
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

        message(:success, success)
        redirect(UserGroups.r(:edit, user_group.id))
      end

      ##
      # Deletes all specified user groups.
      #
      # @since      0.1
      # @permission delete_user_group
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
            Ramaze::Log.error(e)
            message(:error, lang('user_groups.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('user_groups.success.delete'))
        redirect_referrer
      end
    end # UserGroups
  end # Controller
end # Users
