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
    # @author  Yorick Peterse
    # @since   0.1
    #
    class CustomFields < Zen::Controller::AdminController
      include ::CustomFields::Model

      map('/admin/custom-fields')

      # Load all required Javascript files
      javascript ['zen/tabs']

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
      # * custom_fields
      # * custom_field_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url     = CustomFields.r(:save)
        @form_delete_url   = CustomFields.r(:delete)
        
        Zen::Language.load('custom_fields')
        Zen::Language.load('custom_field_groups')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("custom_fields.titles.#{method}") rescue nil
        end

        # Build our array containing all custom field formats
        @field_type_hash = {
          'textbox'         => lang('custom_fields.special.type_hash.textbox'),
          'textarea'        => lang('custom_fields.special.type_hash.textarea'),
          'radio'           => lang('custom_fields.special.type_hash.radio'),
          'checkbox'        => lang('custom_fields.special.type_hash.checkbox'),
          'date'            => lang('custom_fields.special.type_hash.date'),
          'select'          => lang('custom_fields.special.type_hash.select'),
          'select_multiple' => lang('custom_fields.special.type_hash.select_multiple')
        }
      end
      
      ##
      # Show an overview of all existing custom fields. Using this overview a user
      # can manage an existing field, delete it or create a new one.
      #
      # This method requires the following permissions:
      #
      # * read
      # 
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to 
      # which all fields belong.
      # @since  0.1
      #
      def index(custom_field_group_id)
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('custom_field_groups.titles.index'), CustomFieldGroups.r(:index)),
          lang('custom_fields.titles.index')
        )
        
        @custom_field_group_id = custom_field_group_id.to_i
        @custom_fields         = CustomFieldGroup[@custom_field_group_id].custom_fields
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
      # @param  [Integer] custom_field_group_id The ID of the custom field group to 
      # which all fields belong.
      # @param  [Integer] id The ID of the custom field to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit(custom_field_group_id, id)
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('custom_field_groups.titles.index'), CustomFieldGroups.r(:index)),
          anchor_to(lang('custom_fields.titles.index'), CustomFields.r(:index, custom_field_group_id)),
          lang('custom_fields.titles.edit')
        )
          
        @custom_field_group_id = custom_field_group_id

        if flash[:form_data]
          @custom_field = flash[:form_data]
        else
          @custom_field = CustomField[id.to_i]
        end
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
      # @param  [Integer] custom_field_group_id The ID of the custom field group to 
      # which all fields belong.
      # @since  0.1
      #
      def new(custom_field_group_id)
        if !user_authorized?([:read, :create])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(
            lang('custom_field_groups.titles.index'), 
            CustomFieldGroups.r(:index)
          ),
          anchor_to(
            lang('custom_fields.titles.index'), 
            CustomFields.r(:index, custom_field_group_id)
          ),
          lang('custom_fields.titles.index')
        )
        
        @custom_field_group_id = custom_field_group_id
        @custom_field          = CustomField.new
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named 'id' we'll determine
      # if the data will be used to create a new custom field or to update an existing one.
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
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post = request.subset(
          :id, :name, :slug, :description, :sort_order, :type, :format, :possible_values,
          :required, :visual_editor, :textarea_rows, :text_limit, :custom_field_group_id
        )

        # Get or create a custom field group based on the ID from the hidden field.
        if post['id'] and !post['id'].empty?
          @custom_field = CustomField[post['id']]
          save_action   = :save
        else
          @custom_field = CustomField.new
          save_action   = :new
        end

        post.delete('slug') if post['slug'].empty?
        post.delete('id')
        
        flash_success = lang("custom_fields.success.#{save_action}")
        flash_error   = lang("custom_fields.errors.#{save_action}")

        begin
          @custom_field.update(post)
          message(:success, flash_success)
        rescue
          message(:error, flash_error)

          flash[:form_data]   = @custom_field
          flash[:form_errors] = @custom_field.errors
        end
        
        if @custom_field.id
          redirect(CustomFields.r(:edit, post['custom_field_group_id'], @custom_field.id))
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete an existing custom field.
      #
      # In order to delete a custom field group you'll need to send a POST request that 
      # contains a field named 'custom_field_ids[]'. This field should contain the 
      # primary values of each field that has to be deleted.
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        post = request.subset(:custom_field_ids, :custom_field_group_id)
        
        if !request.params['custom_field_ids'] or request.params['custom_field_ids'].empty?
          message(:error, lang('custom_fields.errors.no_delete'))
          redirect(CustomFields.r(:index, post['custom_field_group_id']))
        end
        
        request.params['custom_field_ids'].each do |id|
          begin
            CustomField[id].destroy
            message(:success, lang('custom_fields.success.delete'))
          rescue
            message(:error, lang('custom_fields.errors.delete') % id)
          end
        end
        
        redirect_referrer
      end
    end # CustomFields
  end # Controller
end # CustomFields
