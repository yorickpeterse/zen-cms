#:nodoc:
module CustomFields
  #:nodoc:
  module Controller
    ##
    # Controller for managing custom fields. Custom fields are one of
    # the most important elements in Zen. Custom fields can be used to
    # create radio buttons, textareas, the whole shebang. Before
    # being able to use a custom field you'll need to add it to a group
    # and bind that group to a section.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CustomFields < Zen::Controller::AdminController
      include ::CustomFields::Model

      helper :custom_field

      map '/admin/custom-fields'

      # Load all required Javascript files
      javascript ['lib/zen/tabs']

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Hook that is executed before the index(), edit() and new() methods.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      before(:index, :edit, :new) do
        @custom_field_types = CustomFieldType.type_hash
      end

      ##
      # Constructor method, called upon initialization. It's used to set the
      # URL to which forms send their data and load the language pack.
      #
      # This method loads the following language files:
      #
      # * custom_fields
      # * custom_field_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        Zen::Language.load('custom_fields')
        Zen::Language.load('custom_field_groups')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("custom_fields.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all existing custom fields. Using this overview a
      # user can manage an existing field, delete it or create a new one.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @param  [Fixnum] custom_field_group_id The ID of the custom field group
      # to which all fields belong.
      # @since  0.1
      #
      def index(custom_field_group_id)
        require_permissions(:read)

        field_group = validate_custom_field_group(custom_field_group_id)

        set_breadcrumbs(
          CustomFieldGroups.a(lang('custom_field_groups.titles.index'), :index),
          lang('custom_fields.titles.index')
        )

        @custom_field_group_id = custom_field_group_id
        @custom_fields         = field_group.custom_fields
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
      # @param  [Fixnum] custom_field_group_id The ID of the custom field
      # group to which all fields belong.
      # @param  [Fixnum] id The ID of the custom field to retrieve so that we
      # can edit it.
      # @since  0.1
      #
      def edit(custom_field_group_id, id)
        require_permissions(:read, :update)

        validate_custom_field_group(custom_field_group_id)

        set_breadcrumbs(
          CustomFieldGroups.a(
            lang('custom_field_groups.titles.index'), :index
          ),
          CustomFields.a(
            lang('custom_fields.titles.index'), :index, custom_field_group_id
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
      # This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @param  [Fixnum] custom_field_group_id The ID of the custom field group
      # to which all fields belong.
      # @since  0.1
      #
      def new(custom_field_group_id)
        require_permissions(:read, :create)

        validate_custom_field_group(custom_field_group_id)

        set_breadcrumbs(
          CustomFieldGroups.a(
            lang('custom_field_groups.titles.index'), :index
          ),
          CustomFields.a(
            lang('custom_fields.titles.index'), :index, custom_field_group_id
          ),
          lang('custom_fields.titles.index')
        )

        @custom_field_group_id = custom_field_group_id
        @custom_field          = CustomField.new

        render_view(:form)
      end

      ##
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named 'id' we'll
      # determine if the data will be used to create a new custom field or to
      # update an existing one.
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
          custom_field = validate_custom_field(
            post['id'], post['custom_field_group_id']
          )

          save_action  = :save
        else
          custom_field = CustomField.new
          save_action  = :new
        end

        post.delete('slug') if post['slug'].empty?
        post.delete('id')

        flash_success = lang("custom_fields.success.#{save_action}")
        flash_error   = lang("custom_fields.errors.#{save_action}")

        begin
          custom_field.update(post)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = custom_field
          flash[:form_errors] = custom_field.errors

          redirect_referrer
        end

        if custom_field.id
          redirect(
            CustomFields.r(
              :edit, post['custom_field_group_id'], custom_field.id
            )
          )
        else
          redirect_referrer
        end
      end

      ##
      # Delete an existing custom field.
      #
      # In order to delete a custom field group you'll need to send a POST
      # request that contains a field named 'custom_field_ids[]'. This field
      # should contain the primary values of each field that has to be deleted.
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

        post = request.subset(:custom_field_ids, :custom_field_group_id)

        if !request.params['custom_field_ids'] \
        or request.params['custom_field_ids'].empty?
          message(:error, lang('custom_fields.errors.no_delete'))
          redirect(CustomFields.r(:index, post['custom_field_group_id']))
        end

        request.params['custom_field_ids'].each do |id|
          begin
            CustomField[id].destroy
            message(:success, lang('custom_fields.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('custom_fields.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # CustomFields
  end # Controller
end # CustomFields
