#:nodoc:
module Sections
  #:nodoc:
  module Controller
    ##
    # Section entries can be seen as blog entries, products, all sorts of things.
    # Each section belongs to a section and can't be created without one.
    #
    # ## Used Permissions
    #
    # * show_section_entry
    # * new_section_entry
    # * edit_section_entry
    # * delete_section_entry
    #
    # ## Available Permissions
    #
    # * new_section_entry
    # * edit_section_entry
    # * delete_section_entry
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class SectionEntries < Zen::Controller::AdminController
      map    '/admin/section-entries'
      helper :section
      title  'section_entries.titles.%s'

      load_asset_group [:tabs, :editor, :datepicker], [:edit, :new]
      csrf_protection  :save, :delete

      ##
      # Show an overview of all entries for the current section.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] section_id The ID of the current section.
      # @since  0.1
      #
      def index(section_id)
        authorize_user!(:show_section_entry)

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
        authorize_user!(:new_section_entry)

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

        if flash[:form_data]
          @entry = flash[:form_data]
        else
          @entry = ::Sections::Model::SectionEntry.new(
            :section_id => section_id
          )
        end

        @possible_categories = @entry.possible_categories
        @custom_fields_hash  = @entry.custom_fields_hash

        render_view(:form)
      end

      ##
      # Show a form that lets the user edit an existing section entry.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] section_id The ID of the current section.
      # @param  [Fixnum] entry_id The ID of the current section entry.
      # @since  0.1
      #
      def edit(section_id, entry_id)
        authorize_user!(:edit_section_entry)

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
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named "id" we'll
      # determine if the data will be used to create a new section or to update
      # an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        section_id = request.params['section_id']

        validate_section(section_id)

        if request.params['id'] and !request.params['id'].empty?
          authorize_user!(:edit_section_entry)

          entry       = ::Sections::Model::SectionEntry[request.params['id']]
          save_action = :save
          event       = :edit_section_entry

          # Section entries aren't considered to be updated whenever a custom
          # field value is modified, this solves that problem
          request.params['updated_at'] = Time.new
        else
          authorize_user!(:new_section_entry)

          entry = ::Sections::Model::SectionEntry.new(:section_id => section_id)
          event       = :new_section_entry
          save_action = :new
        end

        request.params.delete('id')

        success       = lang("section_entries.success.#{save_action}")
        error         = lang("section_entries.errors.#{save_action}")
        custom_fields = entry.custom_fields
        field_errors  = {}
        field_values  = {}

        entry.custom_field_values.each do |value|
          field_values[value.custom_field_id] = value
        end

        begin
          Zen.database.transaction do
            # Update the entry itself
            post_data = request.subset(
              :title,
              :created_at,
              :updated_at,
              :section_id,
              :user_id,
              :slug,
              :section_entry_status_id,
              :category_pks
            )

            # Transform the dates properly
            if post_data[:created_at]
              post_data[:created_at] = Time.strptime(
                post_data[:created_at],
                date_format
              )
            end

            if post_data[:updated_at]
              post_data[:updated_at] = Time.strptime(
                post_data[:updated_at],
                date_format
              )
            end

            entry.update(post_data)

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
                  entry.add_custom_field_value(
                    :custom_field_id => field.id,
                    :value           => request.params[key]
                  )
                end
              end
            end
          end
        # The rescue statement is called whenever the following happens:
        #
        # 1. The fields for the section entry (title, slug, etc) are invalid
        # 2. Any custom field marked as required didn't have a value
        # 3. Something else went wrong, god knows what.
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_errors] = entry.errors.merge(field_errors)
          flash[:form_data]   = entry

          redirect_referrer
        end

        Zen::Event.call(event, entry)

        message(:success, success)
        redirect(SectionEntries.r(:edit, section_id, entry.id))
      end

      ##
      # Delete a set of section entries based on the supplied POST
      # field "section_entry_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        authorize_user!(:delete_section_entry)

        if !request.params['section_entry_ids'] \
        or request.params['section_entry_ids'].empty?
          message(:error, lang('section_entries.errors.no_delete'))
          redirect_referrer
        end

        request.params['section_entry_ids'].each do |id|
          entry = ::Sections::Model::SectionEntry[id]

          next if entry.nil?

          begin
            entry.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error,lang('section_entries.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_section_entry, entry)
        end

        message(:success, lang('section_entries.success.delete'))
        redirect_referrer
      end
    end  # SectionEntries
  end # Controller
end # Sections
