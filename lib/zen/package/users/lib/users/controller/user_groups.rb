#:nodoc:
module Users
  #:nodoc:
  module Controller
    ##
    # Controller for managing all user groups. It's not
    # required to add a user to a group but it can certainly
    # make it easier when adding custom permissions or
    # granting a user full access to the backend.
    # 
    # @author Yorick Peterse
    # @since  0.1
    #
    class UserGroups < Zen::Controller::AdminController
      include ::Users::Model

      map   '/admin/user-groups'
      trait :extension_identifier => 'com.zen.users'
      
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
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
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
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('user_groups.titles.index'), UserGroups.r(:index)), 
          lang('user_groups.titles.edit')
        )
        
        if flash[:form_data]
          @user_group = flash[:form_data]
        else
          @user_group = UserGroup[id.to_i]
        end
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
        if !user_authorized?([:read, :create])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('user_groups.titles.index'), UserGroups.r(:index)), 
          lang('user_groups.titles.new')
        )
        
        @user_group = UserGroup.new
      end
      
      ##
      # Saves or creates a new user group based on the POST data and a field named 'id'.
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
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post = request.params.dup
       
        if post['id'] and !post['id'].empty?
          @user_group = UserGroup[post['id']]
          save_action = :save
        else
          @user_group = UserGroup.new
          save_action = :new
        end
        
        flash_success = lang("user_groups.success.#{save_action}")
        flash_error   = lang("user_groups.errors.#{save_action}")
        
        begin
          @user_group.update(post)
          notification(:success, lang('user_groups.titles.index'), flash_success)
        rescue
          notification(:error, lang('user_groups.titles.index'), flash_error)
          
          flash[:form_data]   = @user_group
          flash[:form_errors] = @user_group.errors
        end
        
        if @user_group.id
          redirect(UserGroups.r(:edit, @user_group.id))
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
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        if !request.params['user_group_ids'] or request.params['user_group_ids'].empty?
          notification(
            :error, 
            lang('user_groups.titles.index'), 
            lang('user_groups.errors.no_delete')
          )

          redirect_referrer
        end
        
        request.params['user_group_ids'].each do |id|
          begin
            UserGroup[id.to_i].destroy
            notification(
              :success, 
              lang('user_groups.titles.index'), 
              lang('user_groups.success.delete')
            )
          rescue
            notification(
              :error, 
              lang('user_groups.titles.index'), 
              lang('user_groups.errors.delete') % id
            )
          end
        end
        
        redirect_referrer
      end
    end
  end
end
