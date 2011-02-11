module CustomFields
  module Controllers
    ##
    # Controller for managing custom field groups. These groups are used
    # to organize individual fields into a larger group which in turn will
    # be assigned to a section.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class CustomFieldGroups < Zen::Controllers::AdminController
      map '/admin/custom_field_groups'
      
      trait :extension_identifier => 'com.zen.custom_fields'
      
      include ::CustomFields::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 403)
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
        
        @form_save_url     = '/admin/custom_field_groups/save'
        @form_delete_url   = '/admin/custom_field_groups/delete'
        @field_groups_lang = Zen::Language.load 'custom_field_groups'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @field_groups_lang.titles.key? method
            @page_title = @field_groups_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all existing custom field groups. Using this overview a user
      # can manage an existing field group, delete it or create a new one.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @field_groups_lang.titles[:index]
        
        @field_groups = CustomFieldGroup.all
      end
      
      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the custom field group to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@field_groups_lang.titles[:index], "admin/custom_field_groups"), @page_title
        
        @field_group = CustomFieldGroup[id]
      end
      
      ##
      # Show a form that lets the user create a new custom field group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@field_groups_lang.titles[:index], "admin/custom_field_groups"), @page_title
        
        @field_group = CustomFieldGroup.new
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named "id" we'll determine
      # if the data will be used to create a new group or to update an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
        
        # Get or create a custom field group based on the ID from the hidden field.
        if post["id"] and !post["id"].empty?
          @field_group  = CustomFieldGroup[post["id"]]
          save_action   = :save
        else
          @field_group  = CustomFieldGroup.new
          save_action   = :new
        end
        
        flash_success = @field_groups_lang.success[save_action]
        flash_error   = @field_groups_lang.errors[save_action]
        
        begin
          @field_group.update(post)
          notification(:success, @field_groups_lang.titles[:index], flash_success)
        rescue
          notification(:error, @field_groups_lang.titles[:index], flash_error)
          flash[:form_errors] = @field_group.errors
        end
        
        if @field_group.id
          redirect "/admin/custom_field_groups/edit/#{@field_group.id}"
        else
          redirect "/admin/custom_field_groups/new"
        end
      end
      
      ##
      # Delete an existing custom field group.
      #
      # In order to delete a custom field group you'll need to send a POST request that contains
      # a field named "custom_field_group_ids[]". This field should contain the primary values of
      # each field group that has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["custom_field_group_ids"] or request.params["custom_field_group_ids"].empty?
          notification(:error, @field_groups_lang.titles[:index], @field_groups_lang.errors[:no_delete])
          redirect "/admin/custom_field_groups"
        end
        
        request.params["custom_field_group_ids"].each do |id|
          @field_group = CustomFieldGroup[id]
          
          begin
            @field_group.delete
            notification(:success, @field_groups_lang.titles[:index], @field_groups_lang.success[:delete] % id)
          rescue
            notification(:error, @field_groups_lang.titles[:index], @field_groups_lang.errors[:delete] % id)
          end
        end
        
        redirect "/admin/custom_field_groups"
      end
    end
  end
end
