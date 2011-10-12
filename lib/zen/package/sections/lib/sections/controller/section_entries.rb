module Sections
  #:nodoc:
  module Controller
    ##
    # Section entries are collections of custom field values as well as some
    # meta data related to a section. In a typical application a blog can be
    # seen as a section and blog articles would be section entries.
    #
    # Section entries can be managed by going to a section and clicking the link
    # "Manage entries". This will bring you to an overview of all existing
    # entries that looks like the one in the image below.
    #
    # ![Section Entries](../../_static/sections/entries.png)
    #
    # Editing an entry can be done by clicking on it's name, creating a new one
    # can be done by clicking on the "Add section entry" button. In both cases
    # you'll see a form that looks similar to the one displayed in the images
    # below.
    #
    # ![Edit Entry](../../_static/sections/edit_entry.png)
    # ![Categories](../../_static/sections/edit_entry_categories.png)
    # ![General](../../_static/sections/edit_entry_general.png)
    # ![Meta](../../_static/sections/edit_entry_meta.png)
    #
    # In the images above there are four tabs displayed. "Basic", "Categories",
    # "General" and "Meta". The first two are always available, the last two
    # tabs are tabs specific to the custom field groups assigned to a section
    # the entry belongs to. This means that you might have other tabs depending
    # on the names of your field groups.
    #
    # Regardless of what field groups and categories you have assigned you can
    # always specify the following fields:
    #
    # * **Title** (required): the title of your entry.
    # * **Slug**: a URL friendly version of the title. If no slug is specified
    #   one will be generated manually.
    # * **Created at**: The date on which the entry was created. This field is
    #   filled in automatically when an entry is created.
    # * **Author** (required): the name of the person who wrote the entry.
    # * **Status** (required): the status of an entry. If an entry has a status
    #   other than "Published" it will not be displayed when using the
    #   sectio_entries plugin.
    #
    # Depending on whether or not you have category and field groups assigned
    # you can also use these fields. In the images above there's a "Body" field
    # which is required and converts the text to HTML using Markdown.
    #
    # ## Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_section_entry
    # * new_section_entry
    # * edit_section_entry
    # * delete_section_entry
    #
    # ## Events
    #
    # All events in this controller receive an instance of
    # {Sections::Model::SectionEntry}. The event ``after_delete_section_entry``
    # receives an instance of this model that has already been destroyed using
    # ``#destroy()``.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/section-entries
    # @event  before_new_section_entry
    # @event  after_new_section_entry
    # @event  before_edit_section_entry
    # @event  after_edit_section_entry
    # @event  before_delete_section_entry
    # @event  after_delete_section_entry
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
      # @author     Yorick Peterse
      # @param      [Fixnum] section_id The ID of the current section.
      # @since      0.1
      # @permission show_section_entry
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
      # @author     Yorick Peterse
      # @param      [Fixnum] section_id The ID of the current section.
      # @since      0.1
      # @permission new_section_entry
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
      # @author     Yorick Peterse
      # @param      [Fixnum] section_id The ID of the current section.
      # @param      [Fixnum] entry_id The ID of the current section entry.
      # @since      0.1
      # @permission edit_section_entry
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
      # Saves any changes made to an existing entry and all the field values or
      # creates a new entry.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @event      before_new_section_entry
      # @event      after_new_section_entry
      # @event      before_edit_section_entry
      # @event      after_edit_section_entry
      # @permission edit_section_entry (when editing an entry)
      # @permission new_section_entry (when creating a new entry)
      #
      def save
        section_id = request.params['section_id']

        validate_section(section_id)

        if request.params['id'] and !request.params['id'].empty?
          authorize_user!(:edit_section_entry)

          entry        = ::Sections::Model::SectionEntry[request.params['id']]
          save_action  = :save
          before_event = :before_edit_section_entry
          after_event  = :after_edit_section_entry

          # Section entries aren't considered to be updated whenever a custom
          # field value is modified, this solves that problem
          request.params['updated_at'] = Time.new
        else
          authorize_user!(:new_section_entry)

          entry = ::Sections::Model::SectionEntry.new(:section_id => section_id)
          before_event = :before_new_section_entry
          after_event  = :after_new_section_entry
          save_action  = :new
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

            post_data.each { |k, v| entry.send("#{k}=", v) }
            Zen::Event.call(before_event, entry)

            entry.save

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

        Zen::Event.call(after_event, entry)

        message(:success, success)
        redirect(SectionEntries.r(:edit, section_id, entry.id))
      end

      ##
      # Delete a set of section entries based on the supplied POST
      # field "section_entry_ids".
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission delete_section_entry
      # @event      before_delete_section_entry
      # @event      after_delete_section_entry
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
          Zen::Event.call(:before_delete_section_entry, entry)

          begin
            entry.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error,lang('section_entries.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:after_delete_section_entry, entry)
        end

        message(:success, lang('section_entries.success.delete'))
        redirect_referrer
      end
    end  # SectionEntries
  end # Controller
end # Sections
