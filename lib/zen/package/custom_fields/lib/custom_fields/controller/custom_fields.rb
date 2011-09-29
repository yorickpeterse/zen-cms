#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller for managing custom fields. Custom fields are one of the most
    # important elements in Zen. Custom fields can be used to create radio
    # buttons, textareas, the whole shebang. Before being able to use a custom
    # field you'll need to add it to a group and bind that group to a section.
    #
    # ## Used Permissions
    #
    # * show_custom_field
    # * new_custom_field
    # * edit_custom_field
    # * delete_custom_field
    #
    # ## Available Events
    #
    # * new_custom_field
    # * edit_custom_field
    # * delete_custom_field
    #
    # @author Yorick Peterse
    # @since  0.1
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
      # @since  0.1
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
      # @since  0.1
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
      # @since  0.1
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
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named 'id' we'll
      # determine if the data will be used to create a new custom field or to
      # update an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
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
