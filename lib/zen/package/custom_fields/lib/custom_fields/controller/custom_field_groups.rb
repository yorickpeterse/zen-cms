#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller that allows users to manage custom field groups. Individual
    # fields are managed by the CustomFields controller.
    #
    # ## Used Permissions
    #
    # * show_custom_field_group
    # * new_custom_field_group
    # * edit_custom_field_group
    # * delete_custom_field_group
    #
    # ## Available Events
    #
    # * new_custom_field_group
    # * edit_custom_field_group
    # * delete_custom_field_group
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFieldGroups < Zen::Controller::AdminController
      helper :custom_field
      map    '/admin/custom-field-groups'
      title  'custom_field_groups.titles.%s'

      csrf_protection :save, :delete

      ##
      # Shows an overview that allows the user to manage existing field groups
      # and create new ones.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_custom_field_group)

        set_breadcrumbs(lang('custom_field_groups.titles.index'))

        @field_groups = paginate(::CustomFields::Model::CustomFieldGroup)
      end

      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the custom field group to retrieve so
      #  that we can edit it.
      # @since  0.1
      #
      def edit(id)
        authorize_user!(:edit_custom_field_group)

        set_breadcrumbs(
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          @page_title
        )

        @field_group = flash[:form_data] || validate_custom_field_group(id)

        render_view(:form)
      end

      ##
      # Allows a user to create a new custom field group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        authorize_user!(:new_custom_field_group)

        set_breadcrumbs(
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          @page_title
        )

        if flash[:form_data]
          @field_group = flash[:form_data]
        else
          @field_group = ::CustomFields::Model::CustomFieldGroup.new
        end

        render_view(:form)
      end

      ##
      # Saves or creates a new custom field group. If a valid ID is specified in
      # the POST key "id" an existing row will be updated instead of creating a
      # new one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(:id, :name, :description)

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_custom_field_group)

          field_group = validate_custom_field_group(post['id'])
          save_action = :save
          event       = :new_custom_field_group
        else
          authorize_user!(:new_custom_field_group)

          field_group = ::CustomFields::Model::CustomFieldGroup.new
          save_action = :new
          event       = :edit_custom_field_group
        end

        post.delete('id')

        success = lang("custom_field_groups.success.#{save_action}")
        error   = lang("custom_field_groups.errors.#{save_action}")

        begin
          field_group.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_errors] = field_group.errors
          flash[:form_data]   = field_group

          redirect_referrer
        end

        Zen::Event.call(event, field_group)

        message(:success, success)
        redirect(CustomFieldGroups.r(:edit, field_group.id))
      end

      ##
      # Delete an existing custom field group. The IDs of the groups to remove
      # should be specified in a POST array called "custom_field_group_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        authorize_user!(:delete_custom_field_group)

        if !request.params['custom_field_group_ids'] \
        or request.params['custom_field_group_ids'].empty?
          message(:error, lang('custom_field_groups.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_group_ids'].each do |id|
          group = ::CustomFields::Model::CustomFieldGroup[id]

          next if group.nil?

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('custom_field_groups.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_custom_field_group, group)
        end

        message(:success, lang('custom_field_groups.success.delete'))
        redirect_referrer
      end
    end # CustomFieldGroups
  end # Controller
end # CustomFields
