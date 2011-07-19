#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller that can be used to manage individual custom field types.
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    class CustomFieldTypes < Zen::Controller::AdminController
      include ::CustomFields::Model

      map    '/admin/custom-field-types'
      helper :custom_field

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Creates a new instance of the controller, loads all the required
      # language files and sets the page title.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def initialize
        super

        Zen::Language.load('custom_field_types')

        if !action.method.nil?
          @page_title = lang(
            "custom_field_types.titles.#{action.method}"
          ) rescue nil
        end
      end

      ##
      # Shows an overview of all the available custom field types and allows the
      # user to create new ones, edit existing ones or delete a group of field
      # types.
      #
      # This method requires read permissions for a user to be able to view all
      # the field types.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def index
        require_permissions(:read)

        set_breadcrumbs(lang('custom_field_types.titles.index'))

        @field_types = CustomFieldType.eager(:custom_field_method).all
      end

      ##
      # Allows a user to edit an existing custom field type.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] custom_field_type_id The ID of the custom field type to
      # edit.
      #
      def edit(custom_field_type_id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.edit')
        )

        if flash[:form_data]
          @custom_field_type = flash[:form_data]
        else
          @custom_field_type = validate_custom_field_type(custom_field_type_id)
        end

        @custom_field_methods = CustomFieldMethod.pk_hash(:name)

        render_view :form
      end

      ##
      # Allows a user to add a new custom field type.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def new
        require_permissions(:read, :create)

        set_breadcrumbs(
          CustomFieldTypes.a(lang('custom_field_types.titles.index'), :index),
          lang('custom_field_types.titles.new')
        )

        @custom_field_methods = CustomFieldMethod.pk_hash(:name)
        @custom_field_type    = CustomFieldType.new

        render_view :form
      end

      ##
      # Saves the data submitted by CustomFieldTypes#edit() and
      # CustomFieldTypes#add().
      #
      # This method requires either create or update permissions based on the
      # supplied data.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def save
        require_permissions(:create, :update)

        post = request.subset(
          :id,
          :name,
          :language_string,
          :css_class,
          :serialize,
          :allow_markup,
          :custom_field_method_id
        )

        if post['id'] and !post['id'].empty?
          field_type  = validate_custom_field_type(post['id'])
          save_action = :save
        else
          field_type  = CustomFieldType.new
          save_action = :new
        end

        post.delete('id')

        success = lang("custom_field_types.success.#{save_action}")
        error   = lang("custom_field_types.errors.#{save_action}")

        begin
          field_type.update(post)
          message(:success, success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = field_type
          flash[:form_errors] = field_type.errors

          redirect_referrer
        end

        if field_type.id
          redirect(CustomFieldTypes.r(:edit, field_type.id))
        else
          redirect_referrer
        end
      end

      ##
      # Deletes a number of custom field types.
      #
      # This method requires delete permissions for a user to be able to remove
      # a number of database records.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      def delete
        require_permissions(:delete)

        if !request.params['custom_field_type_ids'] \
        or request.params['custom_field_type_ids'].empty?
          message(:error, lang('custom_field_types.errors.no_delete'))
          redirect_referrer
        end

        request.params['custom_field_type_ids'].each do |id|
          begin
            CustomFieldType[id].destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
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
