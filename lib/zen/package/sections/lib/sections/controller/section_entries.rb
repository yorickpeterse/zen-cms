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
      map    '/admin/section-entries'
      helper :section

      # Load all required Javascript files
      javascript(
        [
          'zen/lib/tabs',
          'zen/lib/editor',
          'zen/lib/editor/markdown',
          'zen/lib/editor/textile',
          'vendor/datepicker'
        ],
        :method => [:edit, :new]
      )

      # Load all required CSS files
      stylesheet(['zen/datepicker'], :method => [:edit, :new])

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
        @page_title = lang("section_entries.titles.#{action.method}") rescue nil
      end

      ##
      # Show an overview of all entries for the current section.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @param  [Fixnum] section_id The ID of the current section.
      # @since  0.1
      #
      def index(section_id)
        require_permissions(:read)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          lang('section_entries.titles.index')
        )

        section     = validate_section(section_id)
        @section_id = section_id
        @entries    = ::Sections::Model::SectionEntry.filter(
          :section_id => section_id
        )

        @entries = paginate(@entries)
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
      # @param  [Fixnum] section_id The ID of the current section.
      # @param  [Fixnum] entry_id The ID of the current section entry.
      # @since  0.1
      #
      def edit(section_id, entry_id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          Sections.a(
            lang('sections.titles.index'), :index
          ),
          SectionEntries.a(
            lang('section_entries.titles.index'), :index, section_id
          ),
          lang('section_entries.titles.edit')
        )

        validate_section(section_id)

        if flash[:form_data]
          @entry = flash[:form_data]
        else
          @entry = validate_section_entry(entry_id, section_id)
        end

        @section_id          = section_id
        @possible_categories = @entry.possible_categories
        @custom_fields_hash  = @entry.custom_fields_hash

        render_view(:form)
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
      # @param  [Fixnum] section_id The ID of the current section.
      # @since  0.1
      #
      def new(section_id)
        require_permissions(:read, :create)

        set_breadcrumbs(
          Sections.a(
            lang('sections.titles.index'), :index
          ),
          SectionEntries.a(
            lang('section_entries.titles.index'), :index, section_id
          ),
          lang('section_entries.titles.new')
        )

        validate_section(section_id)

        @section_id  = section_id
        @entry       = ::Sections::Model::SectionEntry.new(
          :section_id => section_id
        )

        @possible_categories = @entry.possible_categories
        @custom_fields_hash  = @entry.custom_fields_hash

        render_view(:form)
      end

      ##
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named "id" we'll
      # determine if the data will be used to create a new section or to update
      # an existing one.
      #
      # This method requires the following permissions:
      #
      # * create
      # * save
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        section_id = request.params['section_id']

        validate_section(section_id)

        if request.params['id'] and !request.params['id'].empty?
          require_permissions(:update)

          @entry      = ::Sections::Model::SectionEntry[request.params['id']]
          save_action = :save

          # Section entries aren't considered to be updated whenever a custom
          # field value is modified, this solves that problem
          request.params['updated_at'] = Time.new
        else
          require_permissions(:create)

          @entry = ::Sections::Model::SectionEntry.new(
            :section_id => section_id
          )

          save_action = :new
        end

        request.params.delete('slug') if request.params['slug'].empty?
        request.params.delete('id')

        flash_success = lang("section_entries.success.#{save_action}")
        flash_error   = lang("section_entries.errors.#{save_action}")
        custom_fields = @entry.custom_fields
        field_errors  = {}
        field_values  = {}

        @entry.custom_field_values.each do |value|
          field_values[value.custom_field_id] = value
        end

        begin
          Zen.database.transaction do
            # Update the entry itself
            @entry.update(request.subset(
              :title,
              :created_at,
              :updated_at,
              :section_id,
              :user_id,
              :slug,
              :section_entry_status_id,
              :category_pks
            ))

            message(:success, flash_success)

            # Update/add all the custom field values
            custom_fields.each do |field|
              key = "custom_field_value_#{field.id}"

              # The custom field has been submitted, let's see if we have to
              # update it or add it.
              if request.params.key?(key)
                # Validate it
                if field.required and request.params[key].empty?
                  field_errors[:"custom_field_value_#{field.id}"] = \
                    lang('zen_models.presence')

                  raise
                end

                # Update it
                if field_values.key?(field.id)
                  field_values[field.id].update(:value => request.params[key])
                # Add it
                else
                  @entry.add_custom_field_value(
                    :custom_field_id => field.id,
                    :value           => request.params[key]
                  )
                end
              end
            end
          end

        if save_action === :new and !@entry.nil?
          Zen::Hook.call(:new_section_entry, @entry)
        end

        # The rescue statement is called whenever the following happens:
        #
        # 1. The fields for the section entry (title, slug, etc) are invalid
        # 2. Any custom field marked as required didn't have a value
        # 3. Something else went wrong, god knows what.
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_errors] = @entry.errors.merge(field_errors)
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
        require_permissions(:delete)

        if !request.params['section_entry_ids'] \
        or request.params['section_entry_ids'].empty?
          message(:error, lang('section_entries.errors.no_delete'))
          redirect_referrer
        end

        request.params['section_entry_ids'].each do |id|
          begin
            ::Sections::Model::SectionEntry[id].destroy
            message(:success, lang('section_entries.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error,lang('section_entries.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end  # SectionEntries
  end # Controller
end # Sections
