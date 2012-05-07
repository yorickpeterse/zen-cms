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
    # ![Custom Fields](../../images/custom_fields/custom_fields.png)
    #
    # Editing a custom field can be done by clicking on the name of the field,
    # creating a new one can be done by clicking on the button "Add custom
    # field". In both cases you'll be shown a form that looks like the one in
    # the image below.
    #
    # ![General](../../images/custom_fields/edit_custom_field_general.png)
    # ![Settings](../../images/custom_fields/edit_custom_field_settings.png)
    #
    # In this form you can specify the following fields:
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
    #             <td>The name of the custom field.</td>
    #         </tr>
    #         <tr>
    #             <td>Slug</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A URL friendly version of the name. If no value is
    #                 specified the slug will be generated based on the custom
    #                 field's name.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Field type</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The custom field type to use.</td>
    #         </tr>
    #         <tr>
    #             <td>Format</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The markup format for values of this custom field.</td>
    #         </tr>
    #         <tr>
    #             <td>Description</td>
    #             <td>No</td>
    #             <td>Unlimited</td>
    #             <td>
    #                 A description of the custom field, displayed when the user
    #                 hovers over a custom field's form element.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Possible values</td>
    #             <td>No</td>
    #             <td>Unlimited</td>
    #             <td>
    #                 A newline separated list of values that can be specified
    #                 for custom fields that allow multiple values to be
    #                 selected (e.g.  checkboxes). These values can be specified
    #                 by writing "key|value" (where "key" and "value" are the
    #                 name and value of an item) on each line.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Requires a value</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 When set to "Yes" users are required to enter a value for
    #                 the custom field.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Enable a text editor</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 When set to "Yes" the values of the custom field can be
    #                 set using a markup editor.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Textarea rows</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 The amount of rows for a textarea field. This value only
    #                 affects custom fields using the "Textarea" type.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Character limit</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 The maximum amount of characters that a user can enter in
    #                 a field.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Sort order</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 The order in which to display the field when managing a
    #                 section entry.
    #             </td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # * show\_custom\_field
    # * new\_custom\_field
    # * edit\_custom\_field
    # * delete\_custom\_field
    #
    # @since  0.1
    # @map    /admin/custom-fields
    #
    class CustomFields < Zen::Controller::AdminController
      helper :custom_field
      map    '/admin/custom-fields'
      title  'custom_fields.titles.%s'

      autosave Model::CustomField,
        Model::CustomField::COLUMNS,
        :edit_custom_field

      csrf_protection  :save; :delete
      load_asset_group :tabs, [:edit, :new]

      before(:index, :edit, :new) do
        @custom_field_types = Model::CustomFieldType.type_hash
        @boolean_hash       = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }
      end

      ##
      # Show an overview of all existing custom fields. Using this overview a
      # user can manage an existing field, delete it or create a new one.
      #
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
        @custom_fields         = search do |query|
          Model::CustomField \
            .search(query) \
            .filter(:custom_field_group_id => custom_field_group_id) \
            .order(:id.asc)
        end

        @custom_fields ||= Model::CustomField \
          .filter(:custom_field_group_id => custom_field_group_id) \
          .order(:id.asc)

        @custom_fields = paginate(@custom_fields)
      end

      ##
      # Show a form that lets the user edit an existing custom field group.
      #
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
        @custom_field          = validate_custom_field(id, custom_field_group_id)

        @custom_field.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Show a form that lets the user create a new custom field group.
      #
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
        @custom_field          = Model::CustomField.new

        @custom_field.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves the changes made by {#edit} and {#new}.
      #
      # @since      0.1
      # @permission edit_custom_field (when editing a field)
      # @permission new_custom_field (when creating a new field)
      #
      def save
        post = post_fields(*Model::CustomField::COLUMNS)
        id   = request.params['id']

        validate_custom_field_group(post['custom_field_group_id'])

        if id and !id.empty?
          authorize_user!(:edit_custom_field)

          custom_field = validate_custom_field(id, post['custom_field_group_id'])
          save_action  = :save
        else
          authorize_user!(:new_custom_field)

          custom_field = Model::CustomField.new
          save_action  = :new
        end

        success = lang("custom_fields.success.#{save_action}")
        error   = lang("custom_fields.errors.#{save_action}")

        begin
          custom_field.set(post)
          custom_field.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
          flash[:form_errors] = custom_field.errors

          redirect_referrer
        end

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
      # @since      0.1
      # @permission delete_custom_field
      #
      def delete
        authorize_user!(:delete_custom_field)

        post = post_fields(:custom_field_ids)

        if post['custom_field_ids'].nil? or post['custom_field_ids'].empty?
          message(:error, lang('custom_fields.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_ids'].each do |id|
          custom_field = Model::CustomField[id]

          next if custom_field.nil?

          begin
            custom_field.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('custom_fields.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('custom_fields.success.delete'))
        redirect_referrer
      end
    end # CustomFields
  end # Controller
end # CustomFields
