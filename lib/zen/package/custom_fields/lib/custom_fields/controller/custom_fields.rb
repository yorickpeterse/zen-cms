module CustomFields
  #:nodoc:
  module Controller
    ##
    # Custom fields allow you to create fields for your entries in their own
    # format and with their own types. This means you're not restricted to the
    # typical "Title" and "Body" fields you'd get when using other systems.
    #
    # Custom fields can be managed to by going to a custom field group and
    # clicking the link "Manage custom fields" (see
    # {CustomFields::Controller::CustomFieldGroups} for more information). Once
    # you've reached this page you'll see an overview of all your custom fields
    # or a message saying no fields were found (if this is the case).
    #
    # ![Custom Fields](../../_static/custom_fields/custom_fields.png)
    #
    # Editing a custom field can be done by clicking on the name of the field,
    # creating a new one can be done by clicking on the button "Add custom
    # field". In both cases you'll be shown a form that looks like the one in
    # the image below.
    #
    # ![General](../../_static/custom_fields/edit_custom_field_general.png)
    # ![Settings](../../_static/custom_fields/edit_custom_field_settings.png)
    #
    # In this form you can specify the following fields:
    #
    # * **Name** (required): the name of the custom field, can be anything you
    #   like. Examples are "Body" and "Date picker".
    # * **Slug**: a URL friendly version of the name. If none is specified one
    #   will be generated automatically.
    # * **Field type** (required): the type of custom field.
    # * **Format** (required): the markup engine to use for the custom field. If
    #   a custom field type doesn't allow the use of markup this setting will
    #   be ignored.
    # * **Description**: a description of the custom field.
    # * **Possible values**: in case a custom field type allows you to specify
    #   multiple values (such as a checkbox) you can specify a value on each
    #   line. These values can be specified as following:
    #
    #       key|value
    #
    #   Example:
    #
    #       Yes!|yes
    #
    # * **Requires a value**: whether or not this field requires a value.
    # * **Enable a text editor**: when set to "Yes" the user can use the markup
    #   editor when adding/editing a value of a field.
    # * **Textarea rows**: the amount of rows when the field type is a textarea.
    # * **Character limit**: the maximum amount of characters a user can enter
    #   in the field.
    # * **Sort order**: a number that indicates the sort order of the field.
    #
    # ## Used Permissions
    #
    # * show_custom_field
    # * new_custom_field
    # * edit_custom_field
    # * delete_custom_field
    #
    # ## Events
    #
    # All events in this controller receive an instance of
    # {CustomFields::Model::CustomField}. Just like other packages the event
    # ``delete_custom_field`` receives an instance that has already been
    # destroyed, thus you won't be able to make any changes to the object and
    # save them in the database.
    #
    # @example Logging when a field is created
    #  Zen::Event.listen(:new_custom_field) do |field|
    #    Ramaze::Log.info("New custom field: #{field.inspect} by #{user.name}")
    #  end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/custom-fields
    # @event  new_custom_field
    # @event  edit_custom_field
    # @event  delete_custom_field
    #
    class CustomFields < Zen::Controller::AdminController
      helper :custom_field
      map    '/admin/custom-fields'
      title  'custom_fields.titles.%s'

      csrf_protection  :save; :delete
      load_asset_group :tabs, [:edit, :new]

      ##
      # Hook that is executed before the CustomFields#index(),
      # CustomFields#edit() and CustomFields#new() methods.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      before(:index, :edit, :new) do
        @custom_field_types = ::CustomFields::Model::CustomFieldType.type_hash
        @boolean_hash       = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }
      end

      ##
      # Show an overview of all existing custom fields. Using this overview a
      # user can manage an existing field, delete it or create a new one.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] custom_field_group_id The ID of the custom field group
      #  to which all fields belong.
      # @since      0.1
      # @permission show_custom_field
      #
      def index(custom_field_group_id)
        authorize_user!(:show_custom_field)

        set_breadcrumbs(
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          lang('custom_fields.titles.index')
        )

        field_group = validate_custom_field_group(custom_field_group_id)
        @custom_field_group_id = custom_field_group_id
        @custom_fields         = ::CustomFields::Model::CustomField.filter(
          :custom_field_group_id => custom_field_group_id
        )

        @custom_fields = paginate(@custom_fields)
      end

      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the custom field
      #  group to which all fields belong.
      # @param  [Fixnum] id The ID of the custom field to retrieve so that we
      #  can edit it.
      # @since      0.1
      # @permission edit_custom_field
      #
      def edit(custom_field_group_id, id)
        authorize_user!(:edit_custom_field)

        validate_custom_field_group(custom_field_group_id)

        set_breadcrumbs(
          CustomFieldGroups.a(
            lang('custom_field_groups.titles.index'),
            :index
          ),
          CustomFields.a(
            lang('custom_fields.titles.index'),
            :index,
            custom_field_group_id
          ),
          lang('custom_fields.titles.edit')
        )

        @custom_field_group_id = custom_field_group_id

        if flash[:form_data]
          @custom_field = flash[:form_data]
        else
          @custom_field = validate_custom_field(id, custom_field_group_id)
        end

        render_view(:form)
      end

      ##
      # Show a form that lets the user create a new custom field group.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] custom_field_group_id The ID of the custom field group
      #  to which all fields belong.
      # @since      0.1
      # @permission new_custom_field
      #
      def new(custom_field_group_id)
        authorize_user!(:new_custom_field)

        validate_custom_field_group(custom_field_group_id)

        set_breadcrumbs(
          CustomFieldGroups.a(
            lang('custom_field_groups.titles.index'),
            :index
          ),
          CustomFields.a(
            lang('custom_fields.titles.index'),
            :index,
            custom_field_group_id
          ),
          lang('custom_fields.titles.new')
        )

        @custom_field_group_id = custom_field_group_id

        if flash[:form_data]
          @custom_field = flash[:form_data]
        else
          @custom_field = ::CustomFields::Model::CustomField.new
        end

        render_view(:form)
      end

      ##
      # Saves the changes made by {#edit} and {#new}.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @event      new_custom_field
      # @event      edit_custom_field
      # @permission edit_custom_field (when editing a field)
      # @permission new_custom_field (when creating a new field)
      #
      def save
        post = request.subset(
          :id,
          :name,
          :slug,
          :description,
          :sort_order,
          :format,
          :possible_values,
          :required,
          :text_editor,
          :textarea_rows,
          :text_limit,
          :custom_field_group_id,
          :custom_field_type_id
        )

        validate_custom_field_group(post['custom_field_group_id'])

        # Get or create a custom field group based on the ID from the hidden
        # field.
        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_custom_field)

          custom_field = validate_custom_field(
            post['id'], post['custom_field_group_id']
          )

          save_action = :save
          event       = :edit_custom_field
        else
          authorize_user!(:new_custom_field)

          custom_field = ::CustomFields::Model::CustomField.new
          save_action  = :new
          event        = :new_custom_field
        end

        post.delete('id')

        success = lang("custom_fields.success.#{save_action}")
        error   = lang("custom_fields.errors.#{save_action}")

        begin
          custom_field.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = custom_field
          flash[:form_errors] = custom_field.errors

          redirect_referrer
        end

        Zen::Event.call(event, custom_field)

        message(:success, success)
        redirect(
          CustomFields.r(:edit, post['custom_field_group_id'], custom_field.id)
        )
      end

      ##
      # Delete an existing custom field.
      #
      # In order to delete a custom field group you'll need to send a POST
      # request that contains a field named 'custom_field_ids[]'. This field
      # should contain the primary values of each field that has to be deleted.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @event      delete_custom_field
      # @permission delete_custom_field
      #
      def delete
        authorize_user!(:delete_custom_field)

        post = request.subset(:custom_field_ids)

        if post['custom_field_ids'].nil? or post['custom_field_ids'].empty?
          message(:error, lang('custom_fields.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_ids'].each do |id|
          custom_field = ::CustomFields::Model::CustomField[id]

          next if custom_field.nil?

          begin
            custom_field.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('custom_fields.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_custom_field, custom_field)
        end

        message(:success, lang('custom_fields.success.delete'))
        redirect_referrer
      end
    end # CustomFields
  end # Controller
end # CustomFields
