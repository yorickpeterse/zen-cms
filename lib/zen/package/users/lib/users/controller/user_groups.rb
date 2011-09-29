#:nodoc:
module Users
  #:nodoc:
  module Controller
    ##
    # Controller for managing all user groups. It's not required to add a user
    # to a group but it can certainly make it easier when adding custom
    # permissions or granting a user full access to the backend.
    #
    # ## Used Permissions
    #
    # * show_user_group
    # * edit_user_group
    # * new_user_group
    # * delete_user_group
    #
    # ## Available Events
    #
    # * new_user_group
    # * edit_user_group
    # * delete_user_group
    #
    # @author Yorick Peterse
    # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_user_group)

        set_breadcrumbs(lang('user_groups.titles.index'))

        @user_groups = paginate(::Users::Model::UserGroup)
      end

      ##
      # Edit an existing user group.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the user group to edit.
      # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
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
      # Delete all specified user groups.
      #
      # @author Yorick Peterse
      # @since  0.1
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
