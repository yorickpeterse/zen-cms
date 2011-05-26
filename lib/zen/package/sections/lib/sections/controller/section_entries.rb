#:nodoc:
module Sections
  #:nodoc:
  module Controller
    ##
    # Section entries can be seen as blog entries, products, all sorts of things.
    # Each section belongs to a section and can't be created without one.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class SectionEntries < Zen::Controller::AdminController
      include ::Sections::Model 
      
      map '/admin/section-entries'

      # Load all required Javascript files
      javascript ['zen/tabs', 'zen/editor/editor', 'vendor/datepicker']

      # Load all required CSS files
      stylesheet ['zen/datepicker']

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
      # * sections
      # * section_entries
      # * zen_models
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = SectionEntries.r(:save)
        @form_delete_url = SectionEntries.r(:delete)
        
        Zen::Language.load('section_entries')
        Zen::Language.load('sections')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("section_entries.titles.#{method}") rescue nil
        end

        @status_hash = {
          'draft'     => lang('section_entries.special.status_hash.draft'),
          'published' => lang('section_entries.special.status_hash.published')
        }
      end
      
      ##
      # Show an overview of all entries for the current section.
      #
      # This method requires the following permissions:
      #
      # * read
      # 
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @since  0.1
      #
      def index(section_id)
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('sections.titles.index'), Sections.r(:index)),
          lang('section_entries.titles.index')
        )
        
        section     = Section[section_id.to_i]
        @section_id = section_id
        @entries    = section.section_entries
      end
      
      ##
      # Show a form that lets the user edit an existing section entry.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @param  [Integer] entry_id The ID of the current section entry.
      # @since  0.1
      #
      def edit(section_id, entry_id)
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(
            lang('sections.titles.index'), 
            Sections.r(:index)
          ),
          anchor_to(
            lang('section_entries.titles.index'), 
            SectionEntries.r(:index, section_id)
          ),
          lang('section_entries.titles.edit')
        )
        
        @section_id = section_id

        if flash[:form_data]
          @entry = flash[:form_data]
        else
          @entry = SectionEntry[entry_id.to_i]
        end

        @users_hash = {}
        
        Users::Model::User.each { |u| @users_hash[u.id] = u.name }
      end
      
      ##
      # Show a form that lets the user create a new section entry.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @param  [Integer] section_id The ID of the current section.
      # @since  0.1
      #
      def new(section_id)
        if !user_authorized?([:read, :create])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(
            lang('sections.titles.index'), 
            Sections.r(:index)
          ),
          anchor_to(
            lang('section_entries.titles.index'), 
            SectionEntries.r(:index, section_id)
          ),
          lang('section_entries.titles.new')
        )
          
        @section_id = section_id
        @entry      = SectionEntry.new(:section_id => @section_id)
        @users_hash = {}
        
        Users::Model::User.each { |u| @users_hash[u.id] = u.name }
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named "id" we'll determine
      # if the data will be used to create a new section or to update an existing one.
      #
      # This method requires the following permissions:
      #
      # * create
      # * save
      #
      # @author Yorick Peterse
      # @since  0.1
      # @todo The way this method handles the creation of field values might require some
      # patches as it executes quite a few queries. I'll keep it as it is for now.
      #
      def save
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post                = request.params.dup
        section_id          = post['section_id']
        field_values        = post['custom_field_values']
        custom_field_errors = {}
        
        post.delete('custom_field_values')
        post.delete('slug') if post['slug'].empty?
        
        if !post['category_pks'].nil?
          post['category_pks'].map! { |value| value.to_i }
        else
          post['category_pks'] = []
        end

        if post['id'] and !post['id'].empty?
          @entry        = SectionEntry[post['id']]
          save_action   = :save
          
          # Section entries aren't considered to be updated whenever a custom field value
          # is modified, this solves that problem
          post['updated_at'] = Time.new
        else
          @entry        = SectionEntry.new
          save_action   = :new
        end

        post.delete('id')
        
        flash_success = lang("section_entries.success.#{save_action}")
        flash_error   = lang("section_entries.errors.#{save_action}")
        
        # Transactions ahoy!
        begin
          Zen.database.transaction do
            # Update the entry itself
            @entry.update(post)
            message(:success, flash_success)
            
            # Update the field values
            field_values.each do |field_id, value|
              field_value = CustomFields::Model::CustomFieldValue[
                :custom_field_id  => field_id, 
                :section_entry_id => @entry.id
              ]
              
              if field_value.nil?
                field_value = @entry.add_custom_field_value(
                  :section_entry_id => @entry.id, 
                  :custom_field_id  => field_id
                )
              end
              
              # Get the custom field for the current value
              custom_field = field_value.custom_field
              
              if custom_field.required and value.empty?
                custom_field_errors[:"custom_field_values[#{field_id}]"] = \
                  lang('zen_models.presence')
              end
              
              raise unless custom_field_errors.empty?
              
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
          message(:error, flash_error)
            
          flash[:form_errors] = @entry.errors.merge(custom_field_errors)
          flash[:form_data]   = @entry

          redirect_referrer
        end
        
        if @entry.id
          redirect(SectionEntries.r(:edit, section_id, @entry.id))
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete a set of section entries based on the supplied POST
      # field "section_entry_ids".
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
        
        if !request.params['section_entry_ids'] or request.params['section_entry_ids'].empty?
          message(:error, lang('section_entries.errors.no_delete'))
          redirect_referrer
        end
        
        request.params['section_entry_ids'].each do |id|
          begin
            SectionEntry[id].destroy
            message(:success, lang('section_entries.success.delete'))
          rescue
            message(:error,lang('section_entries.errors.delete') % id)
          end
        end
        
        redirect_referrer
      end
    end  # SectionEntries
  end # Controller
end # Sections
