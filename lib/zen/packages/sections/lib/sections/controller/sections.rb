module Sections
  module Controllers
    ##
    # Sections can be seen as mini applications inside your website.
    # Examples of sections can be a blog, pages, a products listing, etc.
    # Before being able to properly add section entries you need to assign
    # the following data to a section:
    #
    # * a category group
    # * a custom field group
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Sections < Zen::Controllers::AdminController
      map '/admin'
      
      trait :extension_identifier => 'com.zen.sections'
      
      include ::Sections::Models
      
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
        
        @form_save_url   = '/admin/save'
        @form_delete_url = '/admin/delete'
        @sections_lang   = Zen::Language.load 'sections'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @sections_lang.titles.key? method 
            @page_title = @sections_lang.titles[method]
          end
        end
      end
    
      ##
      # Show an overview of all existing sections. Using this overview a user
      # can manage an existing section, delete it or create a new one.
      # 
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @sections_lang.titles[:index]
        
        @sections = Section.all
      end
      
      ##
      # Show a form that lets the user edit an existing section.
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the section to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@sections_lang.titles[:index], "admin"), @page_title
        
        @custom_field_group_pk_hash = CustomFields::Models::CustomFieldGroup.pk_hash(:name)
        @category_group_pk_hash     = Categories::Models::CategoryGroup.pk_hash(:name)
        @section                    = Section[id]
      end
      
      ##
      # Show a form that lets the user create a new section.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:create, :read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@sections_lang.titles[:index], "admin"), @page_title
        
        @custom_field_group_pk_hash = CustomFields::Models::CustomFieldGroup.pk_hash(:name)
        @category_group_pk_hash     = Categories::Models::CategoryGroup.pk_hash(:name)
        @section                    = Section.new
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named "id" we'll determine
      # if the data will be used to create a new section or to update an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
       
        post.each do |key, value|
          post.delete(key) if value.empty?
        end

        if post["id"] and !post["id"].empty?
          @section      = Section[post["id"]]
          save_action   = :save
        else
          @section      = Section.new
          save_action   = :new
        end
        
        flash_success = @sections_lang.success[save_action]
        flash_error   = @sections_lang.errors[save_action]
        
        # The primary keys have to be integers otherwise Sequel will soil it's pants
        if !post["custom_field_group_pks"].nil?
          post["custom_field_group_pks"].map! { |value| value.to_i }
        else
          post["custom_field_group_pks"] = []
        end
        
        if !post["category_group_pks"].nil?
          post["category_group_pks"].map! { |value| value.to_i }
        else
          post["category_group_pks"] = [] 
        end
        
        begin
          @section.update(post)
          
          if save_action == :new
            @section.custom_field_group_pks = post['custom_field_group_pks']
            @section.category_group_pks     = post['category_group_pks']
          end
          
          notification(:success, @sections_lang.titles[:index], flash_success)
        rescue
          notification(:error, @sections_lang.titles[:index], flash_error)
          
          flash[:form_errors] = @section.errors
        end
        
        if @section.id
          redirect "/admin/edit/#{@section.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete an existing section. Poor section, what did he do wrong?
      # In order to delete a section you'll need to send a POST request that contains
      # a field named "section_ids[]". This field should contain the primary values of
      # each section that has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["section_ids"] or request.params["section_ids"].empty?
          notification(:error, @sections_lang.titles[:index], @sections_lang.errors[:no_delete])
          redirect_referrer
        end
        
        request.params["section_ids"].each do |id|
          @section = Section[id]
          
          begin
            @section.delete
            notification(:success, @sections_lang.titles[:index], @sections_lang.success[:delete] % id)
          rescue
            notification(:error, @sections_lang.titles[:index], @sections_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end 
  end
end
