#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller for managing custom field groups. These groups are used
    # to organize individual fields into a larger group which in turn will
    # be assigned to a section.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class CustomFieldGroups < Zen::Controller::AdminController
      include ::CustomFields::Model

      helper :custom_field

      map '/admin/custom-field-groups'

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Constructor method, called upon initialization. It's used to set the
      # URL to which forms send their data and load the language pack.
      #
      # This method loads the following language files:
      #
      # * custom_field_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @form_save_url   = CustomFieldGroups.r(:save)
        @form_delete_url = CustomFieldGroups.r(:delete)

        Zen::Language.load('custom_field_groups')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("custom_field_groups.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all existing custom field groups. Using this 
      # overview a user can manage an existing field group, delete it or create 
      # a new one.
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

        set_breadcrumbs(lang('custom_field_groups.titles.index'))

        @field_groups = CustomFieldGroup.all
      end

      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the custom field group to retrieve so 
      # that we can edit it.
      # @since  0.1
      #
      def edit(id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          @page_title
        )

        if flash[:form_data]
          @field_group = flash[:form_data]
        else
          @field_group = validate_custom_field_group(id)
        end
      end

      ##
      # Show a form that lets the user create a new custom field group.
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
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          @page_title
        )

        @field_group = CustomFieldGroup.new
      end

      ##
      # Method used for processing the form data and redirecting the user back 
      # to the proper URL. Based on the value of a hidden field named 'id' we'll 
      # determine if the data will be used to create a new group or to update 
      # an existing one.
      #
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        require_permissions(:create, :update)

        post = request.subset(:id, :name, :description)

        # Get or create a custom field group based on the ID from the hidden 
        # field.
        if post['id'] and !post['id'].empty?
          @field_group  = validate_custom_field_group(post['id'])
          save_action   = :save
        else
          @field_group  = CustomFieldGroup.new
          save_action   = :new
        end

        post.delete('id')

        # Set the messages
        flash_success = lang("custom_field_groups.success.#{save_action}")
        flash_error   = lang("custom_field_groups.errors.#{save_action}")

        begin
          @field_group.update(post)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_errors] = @field_group.errors
          flash[:form_data]   = @field_group

          redirect_referrer
        end

        if !@field_group.nil? and @field_group.id
          redirect(CustomFieldGroups.r(:edit, @field_group.id))
        else
          redirect_referrer
        end
      end

      ##
      # Delete an existing custom field group.
      #
      # In order to delete a custom field group you'll need to send a POST 
      # request that contains a field named 'custom_field_group_ids[]'. This 
      # field should contain the primary values of each field group that has to 
      # be deleted.
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

        if !request.params['custom_field_group_ids'] \
        or request.params['custom_field_group_ids'].empty?
          message(:error, lang('custom_field_groups.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_group_ids'].each do |id|
          begin
            CustomFieldGroup[id.to_i].destroy
            message(:success, lang('custom_field_groups.success.delete'))
          rescue
            message(:error, lang('custom_field_groups.errors.delete') % id)
            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # CustomFieldGroups
  end # Controller
end # CustomFields
