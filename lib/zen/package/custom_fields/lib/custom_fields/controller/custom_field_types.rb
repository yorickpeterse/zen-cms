module CustomFields
  #:nodoc:
  module Controller
    ##
    # Custom field types allow you to create your own types of fields. Being
    # able to create your own field types without having to write any code can
    # be very useful. For example, say you want to be able to create a textarea
    # with a special class (maybe you can to use CKEditor), all you'd have to do
    # is create a new field type, add the class and you're good to go.
    #
    # In order to manage field types you'll have to navigate to
    # ``/admin/custom-field-types``. This can be done by either manually
    # entering the URL into your browser's URL bar or by hovering over the
    # "Custom fields" menu item, this will cause the menu to expand and show a
    # URL called "Custom field types". Clicking this URL will take you to an
    # overview of all existing field types.
    #
    # ![Types](../../images/custom_fields/custom_field_types.png)
    #
    # ## Adding/Editing Field Types
    #
    # Editing a field type can be done by clicking on the name of the field
    # type, creating a new one can be done by clicking the "Add field type"
    # button. In both cases you'll end up at a form that looks like the image
    # below.
    #
    # ![Edit Type](../../images/custom_fields/edit_custom_field_type.png)
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
    #             <td>The name of the custom field type.</td>
    #         </tr>
    #         <tr>
    #             <td>Language string</td>
    #             <td>Yes</td>
    #             <td>255</td>
    #             <td>
    #                 The language string to use when displaying the custom
    #                 field type.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>HTML class</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A space separated list of HTML classes to apply to custom
    #                 fields of this type. The value of this field should match
    #                 the pattern <code>/^[a-zA-Z\-_0-9\s]*$/</code>
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Serialize</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 When set the values of custom fields of this type will be
    #                 serialized using Ruby's Marshal module. This setting is
    #                 useful for fields that can have multiple values such as
    #                 checkboxes.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Allow markup</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 When set custom fields of this type can contain markup
    #                 other than plain text.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Custom field method</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>
    #                 The name of the method in the module
    #                 {CustomFields::BlueFormParameters}. This method will be
    #                 used for generating the required markup for each field of
    #                 this type.
    #             </td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # * show_custom_field_type
    # * edit_custom_field_type
    # * new_custom_field_type
    # * delete_custom_field_type
    #
    # @since  0.2.8
    # @map    /admin/custom-field-types
    #
    class CustomFieldTypes < Zen::Controller::AdminController
      map    '/admin/custom-field-types'
      helper :custom_field
      title  'custom_field_types.titles.%s'

      csrf_protection :save, :delete

      autosave Model::CustomFieldType,
        Model::CustomFieldType::COLUMNS,
        :edit_custom_field_type

      before(:index, :edit, :new) do
        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }
      end

      ##
      # Shows an overview of all the available custom field types and allows the
      # user to create new ones, edit existing ones or delete a group of field
      # types.
      #
      # @since      0.2.8
      # @permission show_custom_field_type
      #
      def index
        authorize_user!(:show_custom_field_type)

        set_breadcrumbs(lang('custom_field_types.titles.index'))

        @field_types = search do |query|
          Model::CustomFieldType.search(query).order(:id.asc)
        end

        @field_types ||= Model::CustomFieldType \
          .eager(:custom_field_method) \
          .order(:id.asc)

        @field_types = paginate(@field_types)
      end

      ##
      # Allows a user to edit an existing custom field type.
      #
      # @since      0.2.8
      # @param      [Fixnum] id The ID of the custom field type to edit.
      # @permission edit_custom_field_type
      #
      def edit(id)
        authorize_user!(:edit_custom_field_type)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.edit')
        )

        @custom_field_type    = validate_custom_field_type(id)
        @custom_field_methods = Model::CustomFieldMethod.pk_hash(:name)

        @custom_field_type.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Allows a user to add a new custom field type.
      #
      # @since      0.2.8
      # @permission new_custom_field_type
      #
      def new
        authorize_user!(:new_custom_field_type)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.new')
        )

        @custom_field_methods = Model::CustomFieldMethod.pk_hash(:name)
        @custom_field_type    = Model::CustomFieldType.new

        @custom_field_type.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Creates a new custom field type or edits an existing one.
      #
      # @since      0.2.8
      # @permission edit_custom_field_type (when editing a field type)
      # @permission new_custom_field_type (when creating a field type)
      #
      def save
        post = post_fields(*Model::CustomFieldType::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_custom_field_type)

          field_type  = validate_custom_field_type(id)
          save_action = :save
        else
          authorize_user!(:new_custom_field_type)

          field_type  = Model::CustomFieldType.new
          save_action = :new
        end

        success = lang("custom_field_types.success.#{save_action}")
        error   = lang("custom_field_types.errors.#{save_action}")

        begin
          field_type.set(post)
          field_type.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
          flash[:form_errors] = field_type.errors

          redirect_referrer
        end

        message(:success, success)
        redirect(CustomFieldTypes.r(:edit, field_type.id))
      end

      ##
      # Deletes a number of custom field types. These types should be specified
      # in the POST array "custom_field_type_ids".
      #
      # @since      0.2.8
      # @permission delete_custom_field_type
      #
      def delete
        authorize_user!(:delete_custom_field_type)

        if !request.params['custom_field_type_ids'] \
        or request.params['custom_field_type_ids'].empty?
          message(:error, lang('custom_field_types.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_type_ids'].each do |id|
          type = Model::CustomFieldType[id]

          next if type.nil?

          begin
            type.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('custom_field_types.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('custom_field_types.success.delete'))
        redirect_referrer
      end
    end # CustomFieldTypes
  end # Controller
end # CustomFields
