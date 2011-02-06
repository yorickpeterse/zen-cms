module CustomFields
  module Controllers
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
    class CustomFields < Zen::Controllers::AdminController
      map '/admin/custom_fields'
      
      trait :extension_identifier => 'com.yorickpeterse.custom_fields'
      
      include ::CustomFields::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 401)
        end
      end
      
      ##
      # Constructor method, called upon initialization. It's used to set the
      # URL to which forms send their data and load the language pack.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url     = '/admin/custom_fields/save'
        @form_delete_url   = '/admin/custom_fields/delete'
        @fields_lang       = Zen::Language.load 'custom_fields'
        @field_groups_lang = Zen::Language.load 'custom_field_groups'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @fields_lang.titles.key? method
            @page_title = @fields_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all existing custom fields. Using this overview a user
      # can manage an existing field, delete it or create a new one.
      # 
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @since  0.1
      #
      def index custom_field_group_id
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@field_groups_lang.titles[:index], "admin/custom_field_groups"),
          @fields_lang.titles[:index]
        
        @custom_field_group_id  = custom_field_group_id
        @custom_fields          = CustomFieldGroup[@custom_field_group_id].custom_fields
      end
      
      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @param  [Integer] id The ID of the custom field to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit custom_field_group_id, id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@field_groups_lang.titles[:index], "admin/custom_field_groups"),
          anchor_to(@fields_lang.titles[:index], "admin/custom_fields/#{custom_field_group_id}"),
          @fields_lang.titles[:edit]
          
        @custom_field_group_id = custom_field_group_id
        @custom_field          = CustomField[id]
      end
      
      ##
      # Show a form that lets the user create a new custom field group.
      #
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @since  0.1
      #
      def new custom_field_group_id
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@field_groups_lang.titles[:index], "admin/custom_field_groups"),
          anchor_to(@fields_lang.titles[:index], "admin/custom_fields/#{custom_field_group_id}"),
          @fields_lang.titles[:index]
        
        @custom_field_group_id = custom_field_group_id
        @custom_field          = CustomField.new
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named "id" we'll determine
      # if the data will be used to create a new custom field or to update an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post                  = request.params.dup
        custom_field_group_id = post["custom_field_group_id"]
        
        post.each do |key, value|
          post.delete(key) if value.empty?
        end
        
        # Get or create a custom field group based on the ID from the hidden field.
        if post["id"] and !post["id"].empty?
          @custom_field = CustomField[post["id"]]
          save_action   = :save
        else
          @custom_field = CustomField.new
          save_action   = :new
        end
        
        flash_success = @fields_lang.success[save_action]
        flash_error   = @fields_lang.errors[save_action]

        begin
          @custom_field.update(post)
          notification(:success, @fields_lang.titles[:index], flash_success)
        rescue
          notification(:error, @fields_lang.titles[:index], flash_error)
          flash[:form_errors] = @custom_field.errors
        end
        
        if @custom_field.id
          redirect "/admin/custom_fields/edit/#{custom_field_group_id}/#{@custom_field.id}"
        else
          redirect "/admin/custom_fields/new/#{custom_field_group_id}"
        end
      end
      
      ##
      # Delete an existing custom field.
      #
      # In order to delete a custom field group you'll need to send a POST request that contains
      # a field named "custom_field_ids[]". This field should contain the primary values of
      # each field that has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["custom_field_ids"] or request.params["custom_field_ids"].empty?
          notification(:error, @fields_lang.titles[:index], @fields_lang.errors[:no_delete])
          redirect "/admin/custom_fields/index/#{post['custom_field_group_id']}"
        end
        
        request.params["custom_field_ids"].each do |id|
          @custom_field = CustomField[id]
          
          begin
            @custom_field.delete
            notification(:success, @fields_lang.titles[:index], @fields_lang.success[:delete] % id)
          rescue
            notification(:error, @fields_lang.titles[:index], @fields_lang.errors[:delete] % id)
          end
        end
        
        redirect "/admin/custom_fields/index/#{request.params['custom_field_group_id']}"
      end
    end
  end
end
