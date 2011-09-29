#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller that can be used to manage individual custom field types.
    #
    # ## Used Permissions
    #
    # * show_custom_field_type
    # * edit_custom_field_type
    # * new_custom_field_type
    # * delete_custom_field_type
    #
    # ## Available Events
    #
    # * new_custom_field_type
    # * edit_custom_field_type
    # * delete_custom_field_type
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class CustomFieldTypes < Zen::Controller::AdminController
      map    '/admin/custom-field-types'
      helper :custom_field
      title  'custom_field_types.titles.%s'

      csrf_protection :save, :delete

      # Blck that's executed before CustomFieldTypes#edit() and
      # CustomFieldTypes#new().
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
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def index
        authorize_user!(:show_custom_field_type)

        set_breadcrumbs(lang('custom_field_types.titles.index'))

        @field_types = paginate(
          ::CustomFields::Model::CustomFieldType.eager(:custom_field_method)
        )
      end

      ##
      # Allows a user to edit an existing custom field type.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] id The ID of the custom field type to edit.
      #
      def edit(id)
        authorize_user!(:edit_custom_field_type)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.edit')
        )

        @custom_field_type = flash[:form_data] || validate_custom_field_type(id)
        @custom_field_methods = ::CustomFields::Model::CustomFieldMethod \
          .pk_hash(:name)

        render_view(:form)
      end

      ##
      # Allows a user to add a new custom field type.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def new
        authorize_user!(:new_custom_field_type)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.new')
        )

        @custom_field_methods = ::CustomFields::Model::CustomFieldMethod \
          .pk_hash(:name)

        if flash[:form_data]
          @custom_field_type = flash[:form_data]
        else
          @custom_field_type = ::CustomFields::Model::CustomFieldType.new
        end

        render_view(:form)
      end

      ##
      # Creates a new custom field type or edits an existing one.
      #
      # This method requires either create or update permissions based on the
      # supplied data.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def save
        post = request.subset(
          :id,
          :name,
          :language_string,
          :html_class,
          :serialize,
          :allow_markup,
          :custom_field_method_id
        )

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_custom_field_type)

          field_type  = validate_custom_field_type(post['id'])
          save_action = :save
          event       = :edit_custom_field_type
        else
          authorize_user!(:new_custom_field_type)

          field_type  = ::CustomFields::Model::CustomFieldType.new
          save_action = :new
          event       = :new_custom_field_type
        end

        post.delete('id')

        success = lang("custom_field_types.success.#{save_action}")
        error   = lang("custom_field_types.errors.#{save_action}")

        begin
          field_type.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = field_type
          flash[:form_errors] = field_type.errors

          redirect_referrer
        end

        Zen::Event.call(event, field_type)

        message(:success, success)
        redirect(CustomFieldTypes.r(:edit, field_type.id))
      end

      ##
      # Deletes a number of custom field types. These types should be specified
      # in the POST array "custom_field_type_ids".
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def delete
        authorize_user!(:delete_custom_field_type)

        if !request.params['custom_field_type_ids'] \
        or request.params['custom_field_type_ids'].empty?
          message(:error, lang('custom_field_types.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_type_ids'].each do |id|
          type = ::CustomFields::Model::CustomFieldType[id]

          next if type.nil?

          begin
            type.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('custom_field_types.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_custom_field_type, type)
        end

        message(:success, lang('custom_field_types.success.delete'))
        redirect_referrer
      end
    end # CustomFieldTypes
  end # Controller
end # CustomFields
