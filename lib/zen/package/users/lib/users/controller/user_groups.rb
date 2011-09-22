#:nodoc:
module Users
  #:nodoc:
  module Controller
    ##
    # Controller for managing all user groups. It's not required to add a user
    # to a group but it can certainly make it easier when adding custom
    # permissions or granting a user full access to the backend.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class UserGroups < Zen::Controller::AdminController
      helper :users
      map '/admin/user-groups'

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      serve(:javascript, ['/admin/js/users/permissions'], :minify => false)
      serve(:css, ['/admin/css/users/permissions.css'], :minify => false)

      load_asset_group(:tabs)

      ##
      # Creates a new instance of the controller.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @page_title   = lang("user_groups.titles.#{action.method}") rescue nil
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
        require_permissions(:show_user_group)

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
        require_permissions(:edit_user_group)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.edit')
        )

        if flash[:form_data]
          @user_group = flash[:form_data]
        else
          @user_group = validate_user_group(id)
        end

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
        require_permissions(:new_user_group)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.new')
        )

        @user_group = ::Users::Model::UserGroup.new

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
          require_permissions(:edit_user_group)

          user_group  = validate_user_group(post['id'])
          save_action = :save
        else
          require_permissions(:new_user_group)

          user_group  = ::Users::Model::UserGroup.new
          save_action = :new

          post.delete('slug') if post['slug'].empty?
        end

        post.delete('id')

        flash_success = lang("user_groups.success.#{save_action}")
        flash_error   = lang("user_groups.errors.#{save_action}")

        begin
          user_group.update(post)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = user_group
          flash[:form_errors] = user_group.errors

          redirect_referrer
        end

        if user_authorized?([:edit_permission])
          update_permissions(
            :user_group_id,
            user.id,
            request.params['permissions'] || [],
            user_group.permissions.map { |p| p.permission }
          )
        end

        if user_group.id
          redirect(UserGroups.r(:edit, user_group.id))
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
        require_permissions(:delete_user_group)

        if !request.params['user_group_ids'] \
        or request.params['user_group_ids'].empty?
          message(:error, lang('user_groups.errors.no_delete'))
          redirect_referrer
        end

        request.params['user_group_ids'].each do |id|
          begin
            ::Users::Model::UserGroup[id].destroy
            message(:success,  lang('user_groups.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('user_groups.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # UserGroups
  end # Controller
end # Users
