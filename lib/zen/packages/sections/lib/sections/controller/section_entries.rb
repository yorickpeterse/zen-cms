module Sections
  module Controllers
    ##
    # Section entries can be seen as blog entries, products, all sorts of things.
    # Each section belongs to a section and can't be created without one.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class SectionEntries < Zen::Controllers::AdminController
      map '/admin/section_entries'
      
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
        
        @form_save_url   = '/admin/section_entries/save'
        @form_delete_url = '/admin/section_entries/delete'
        @entries_lang    = Zen::Language.load 'section_entries'
        @sections_lang   = Zen::Language.load 'sections'
        @models_lang     = Zen::Language.load 'zen_models'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @entries_lang.titles.key? method
            @page_title = @entries_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all entries for the current section
      # 
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @since  0.1
      #
      def index section_id
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@sections_lang.titles[:index], "admin"),
          @entries_lang.titles[:index]
        
        section     = Section[section_id]
        @section_id = section_id
        @entries    = section.section_entries
      end
      
      ##
      # Show a form that lets the user edit an existing section entry.
      #
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @param  [Integer] entry_id The ID of the current section entry.
      # @since  0.1
      #
      def edit section_id, entry_id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@sections_lang.titles[:index], "admin"),
          anchor_to(@entries_lang.titles[:index], "admin/section_entries/index/#{section_id}"),
          @entries_lang.titles[:edit]
        
        @section_id = section_id
        @entry      = SectionEntry[entry_id]
        @users_hash = {}
        
        Users::Models::User.each do |u|
          @users_hash[u.id] = u.name
        end
      end
      
      ##
      # Show a form that lets the user create a new section entry.
      #
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @since  0.1
      #
      def new section_id
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@sections_lang.titles[:index], "admin"),
          anchor_to(@entries_lang.titles[:index], "admin/section_entries/index/#{section_id}"),
          @entries_lang.titles[:new]
          
        @section_id = section_id
        @entry      = SectionEntry.new :section_id => @section_id
        @users_hash = {}
        
        Users::Models::User.each do |u|
          @users_hash[u.id] = u.name
        end
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named "id" we'll determine
      # if the data will be used to create a new section or to update an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @todo The way this method handles the creation of field values might require some
      # patches as it executes quite a few queries. I'll keep it as it is for now.
      #
      def save
        if !user_authorized?([:create, :save])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post                = request.params.dup
        section_id          = post["section_id"]
        field_values        = post["custom_field_values"]
        custom_field_errors = {}
        
        post.delete("custom_field_values")
        
        post.each do |key, value|
          post.delete(key) if value.empty?
        end
        
        if !post["category_pks"].nil?
          post["category_pks"].map! { |value| value.to_i }
        else
          post["category_pks"] = []
        end

        if post["id"] and !post["id"].empty?
          @entry        = SectionEntry[post["id"]]
          save_action   = :save
          
          # Section entries aren't considered to be updated whenever a custom field value
          # is modified, this solves that problem
          post['updated_at'] = Time.new
        else
          @entry        = SectionEntry.new
          save_action   = :new
        end
        
        flash_success = @entries_lang.success[save_action]
        flash_error   = @entries_lang.errors[save_action]
        
        # Transactions ahoy!
        begin
          Zen::Database.handle.transaction do
            # Update the entry itself
            @entry.update(post)
            notification(:success, @entries_lang.titles[:index], flash_success)
            
            # Update the field values
            field_values.each do |field_id, value|
              field_value = CustomFields::Models::CustomFieldValue[:custom_field_id => field_id, :section_entry_id => @entry.id]
              
              if field_value.nil?
                field_value = @entry.add_custom_field_value(:section_entry_id => @entry.id, :custom_field_id => field_id)
              end
              
              # Get the custom field for the current value
              custom_field = field_value.custom_field
              
              if custom_field.required and value.empty?
                custom_field_errors[:"custom_field_values[#{field_id}]"] = @models_lang.presence
              end
              
              # Validate the entry
              if !custom_field_errors.empty?
                # No need for a particular exception as Sequel will undo the changes anyway
                raise
              end
              
              field_value.value = value
              field_value.save
            end
          end
        
        # The rescue statement is called whenever the following happens:
        # 
        # 1. The fields for the section entry (title, slug, etc) are invalid
        # 2. Any custom field marked as required didn't have a value
        # 3. Something else went wrong, god knows what.
        rescue
          notification(:error, @entries_lang.titles[:index], flash_error)
            
          flash[:form_errors] = @entry.errors.merge(custom_field_errors)
          redirect_referrer
        end
        
        if @entry.id
          redirect "/admin/section_entries/edit/#{section_id}/#{@entry.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete a set of section entries based on the supplied POST
      # field "section_entry_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["section_entry_ids"] or request.params["section_entry_ids"].empty?
          notification(:error, @entries_lang.titles[:index], @entries_lang.errors[:no_delete])
          redirect_referrer
        end
        
        request.params["section_entry_ids"].each do |id|
          @entry = SectionEntry[id]
          
          begin
            @entry.delete
            notification(:success, @entries_lang.titles[:index], @entries_lang.success[:delete] % id)
          rescue
            notification(:error, @entries_lang.titles[:index], @entries_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end 
  end
end
