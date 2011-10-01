##
# Package for managing custom field groups, custom fields and custom field
# types.
#
# ## Controllers
#
# * {CustomFields::Controller::CustomFieldGroups}
# * {CustomFields::Controller::CustomFields}
# * {CustomFields::Controller::CustomFieldTypes}
#
# ## Helpers
#
# * {Ramaze::Helper::CustomField}
#
# ## Models
#
# * {CustomFields::Model::CustomFieldGroup}
# * {CustomFields::Model::CustomField}
# * {CustomFields::Model::CustomFieldType}
# * {CustomFields::Model::CustomFieldMethod}
# * {CustomFields::Model::CustomFieldValue}
#
# ## Other
#
# * {CustomFields::BlueFormParameters}
#
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Custom field groups allow you to group various fields into groups which in
    # turn can be assigned to a number of sections. Managing your groups can be
    # done by navigating to ``/admin/custom-field-groups``. If you have any
    # existing groups these will be displayed, otherwise a message telling you
    # that do don't have any groups will be displayed instead.
    #
    # ![Custom Field Groups](../../_static/custom_field_groups.png)
    #
    # Just like with other packages you can delete records by clicking the
    # checkboxes followed by the "Delete selected groups" button. Groups can be
    # edited by clicking on the name of a group. If you want to manage the
    # fields of a group you should click on the "Manage custom fields" link.
    #
    # ## Adding/Editing Groups
    #
    # ![Edit Custom Field Group](../../_static/edit_custom_field_group.png)
    #
    # When creating a new group or editing an existing group you can fill in the
    # following two fields:
    #
    # * **Name** (required): the name of the group, an example of such a name is
    #   "General group" or "Meta fields".
    # * **Description**: a description of the group.
    #
    # Note that the length of the group name can not be longer than 255
    # characters.
    #
    # ## Used Permissions
    #
    # * show_custom_field_group
    # * new_custom_field_group
    # * edit_custom_field_group
    # * delete_custom_field_group
    #
    # ## Events
    #
    # All events in this controller receive an instance of
    # {CustomFields::Model::CustomFieldGroup}. The ``delete_custom_field_group``
    # event will receive an instance of this model that has already been
    # destroyed.
    #
    # @example Logging when a group is changed
    #  Zen::Event.listen(:edit_custom_field_group) do |group|
    #    Ramaze::Log.info("Field group ##{group.id} was edited by #{user.name}")
    #  end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/custom-field-groups
    # @event  new_custom_field_group
    # @event  edit_custom_field_group
    # @event  delete_custom_field_group
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
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_custom_field_group
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
      # @since      0.1
      # @permission edit_custom_field_group
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
      # @author     Yorick Peterse
      # @since      0.1
      # @permission new_custom_field_group
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
      # @author     Yorick Peterse
      # @since      0.1
      # @permission edit_custom_field_group (when editing a group)
      # @permission new_custom_field_group (when creating a group)
      # @event      edit_custom_field_group
      # @event      new_custom_field_group
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
      # @author     Yorick Peterse
      # @since      0.1
      # @permission delete_custom_field_group
      # @event      delete_custom_field_group
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
