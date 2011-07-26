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
      include ::Users::Model

      helper :users
      map '/admin/user-groups'

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Load our language packs, set the form URLs and define our page title.
      #
      # This method loads the following language files:
      #
      # * user_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @form_save_url   = UserGroups.r(:save)
        @form_delete_url = UserGroups.r(:delete)

        Zen::Language.load('user_groups')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("user_groups.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all user groups and allow the current user
      # to manage these groups
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        require_permissions(:read)

        set_breadcrumbs(lang('user_groups.titles.index'))

        @user_groups = UserGroup.all
      end

      ##
      # Edit an existing user group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the user group to edit.
      # @since  0.1
      #
      def edit(id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.edit')
        )

        if flash[:form_data]
          @user_group = flash[:form_data]
        else
          @user_group = validate_user_group(id)
        end

        render_view(:form)
      end

      ##
      # Create a new user group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        require_permissions(:read, :create)

        set_breadcrumbs(
          UserGroups.a(lang('user_groups.titles.index'), :index),
          lang('user_groups.titles.new')
        )

        @user_group = UserGroup.new

        render_view(:form)
      end

      ##
      # Saves or creates a new user group based on the POST data and a field
      # named 'id'.
      #
      # This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(:id, :name, :slug, :description, :super_group)

        if post['id'] and !post['id'].empty?
          require_permissions(:update)

          user_group  = validate_user_group(post['id'])
          save_action = :save
        else
          require_permissions(:create)

          user_group  = UserGroup.new
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

        if user_group.id
          redirect(UserGroups.r(:edit, user_group.id))
        else
          redirect_referrer
        end
      end

      ##
      # Delete all specified user groups.
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        require_permissions(:delete)

        if !request.params['user_group_ids'] \
        or request.params['user_group_ids'].empty?
          message(:error, lang('user_groups.errors.no_delete'))
          redirect_referrer
        end

        request.params['user_group_ids'].each do |id|
          begin
            UserGroup[id].destroy
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
