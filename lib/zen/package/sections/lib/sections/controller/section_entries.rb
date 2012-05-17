require 'time'

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
    # ![Section Entries](../../images/sections/entries.png)
    #
    # Editing an entry can be done by clicking on it's name, creating a new one
    # can be done by clicking on the "Add section entry" button. In both cases
    # you'll see a form that looks similar to the one displayed in the images
    # below.
    #
    # ![Edit Entry](../../images/sections/edit_entry.png)
    # ![Categories](../../images/sections/edit_entry_categories.png)
    # ![General](../../images/sections/edit_entry_general.png)
    # ![Meta](../../images/sections/edit_entry_meta.png)
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
    # <table class="table full">
    #     <thead>
    #         <tr>
    #             <th class="field_name">Field</th>
    #             <th>Required</th>
    #             <th>Maximum Length</th>
    #             <th>Description</th>
    #         </tr>
    #     </thead>
    #     <tbody>
    #         <tr>
    #             <td>Title</td>
    #             <td>Yes</td>
    #             <td>255</td>
    #             <td>The title of the section entry.</td>
    #         </tr>
    #         <tr>
    #             <td>Slug</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A URL friendly version of the title. If no value is specified
    #                 one will be generated automatically.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Creatd at</td>
    #             <td>No</td>
    #             <td></td>
    #             <td>
    #                 The date on which the article was created. If no date is
    #                 specified one will be set automatically.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Author</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The name of the author of the entry.</td>
    #         </tr>
    #         <tr>
    #             <td>Status</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The status of the section entry.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # Depending on whether or not you have category and field groups assigned
    # you can also use these fields. In the images above there's a "Body" field
    # which is required and converts the text to HTML using Markdown.
    #
    # ## Permissions
    #
    # This controller uses the following permissions:
    #
    # * show\_section\_entry
    # * new\_section\_entry
    # * edit\_section\_entry
    # * delete\_section\_entry
    #
    # @since  0.1
    # @map    /admin/section-entries
    #
    class SectionEntries < Zen::Controller::AdminController
      map    '/admin/section-entries'
      helper :section
      title  'section_entries.titles.%s'

      load_asset_group [:tabs, :editor, :datepicker], [:edit, :new]
      csrf_protection  :save, :delete, :autosave

      ##
      # Show an overview of all entries for the current section.
      #
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
        @entries    = search do |query|
          ::Sections::Model::SectionEntry.search(query) \
            .filter(:section_id => section_id) \
            .order(:id.asc)
        end

        @entries  ||= ::Sections::Model::SectionEntry \
          .filter(:section_id => section_id) \
          .order(:id.asc)

        @entries = paginate(@entries)
      end

      ##
      # Show a form that lets the user create a new section entry.
      #
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

        @section_id = section_id
        @entry      = Model::SectionEntry.new(:section_id => section_id)

        @entry.set(flash[:form_data]) if flash[:form_data]

        @possible_categories = @entry.possible_categories
        @custom_fields_hash  = @entry.custom_fields_hash

        render_view(:form)
      end

      ##
      # Show a form that lets the user edit an existing section entry.
      #
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

        @entry = validate_section_entry(entry_id, section_id)
        @entry.set(flash[:form_data]) if flash[:form_data]

        @section_id          = section_id
        @possible_categories = @entry.possible_categories
        @custom_fields_hash  = @entry.custom_fields_hash

        render_view(:form)
      end

      ##
      # Saves any changes made to an existing entry and all the field values or
      # creates a new entry.
      #
      # @since      0.1
      # @permission edit_section_entry (when editing an entry)
      # @permission new_section_entry (when creating a new entry)
      #
      def save
        post_data  = post_fields(*Model::SectionEntry::COLUMNS)
        section_id = request.params['section_id']

        if post_data['created_at']
          post_data['created_at'] = Time.strptime(
            post_data['created_at'],
            Model::SectionEntry::DATE_FORMAT
          )
        end

        if request.params['id'] and !request.params['id'].empty?
          authorize_user!(:edit_section_entry)

          entry       = validate_section_entry(request.params['id'], section_id)
          save_action = :save
        else
          authorize_user!(:new_section_entry)

          entry       = Model::SectionEntry.new(:section_id => section_id)
          save_action = :new
        end

        success      = lang("section_entries.success.#{save_action}")
        error        = lang("section_entries.errors.#{save_action}")
        field_errors = {}
        field_values = {}

        begin
          Zen.database.transaction do
            entry.set(post_data)
            entry.save

            field_errors = process_custom_fields(entry)

            raise unless field_errors.empty?
          end
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          request.POST.delete('id')

          flash[:form_errors] = entry.errors.merge(field_errors)
          flash[:form_data]   = request.POST

          redirect_referrer
        end

        message(:success, success)
        redirect(SectionEntries.r(:edit, section_id, entry.id))
      end

      ##
      # Automatically saves a section entry. This is needed to take care of the
      # custom fields, something the helper method itself can not do.
      #
      # @since 2012-02-17
      #
      def autosave
        entry        = Model::SectionEntry[request.params['id']]
        post_data    = post_fields(*Model::SectionEntry::COLUMNS)
        field_errors = {}

        if post_data['created_at']
          post_data['created_at'] = Time.strptime(
            post_data['created_at'],
            Model::SectionEntry::DATE_FORMAT
          )
        end

        if entry.nil? or !user_authorized?(:edit_section_entry)
          respond_json(
            {:error => lang('zen_general.errors.invalid_request')},
            404
          )
        end

        begin
          Zen.database.transaction do
            entry.set(post_data)
            entry.save

            field_errors = process_custom_fields(entry)

            raise unless field_errors.empty?
          end
        rescue => e
          Ramaze::Log.error(e)

          respond_json({:errors => entry.errors.merge(field_errors)}, 400)
        end

        respond_json({:csrf_token => get_csrf_token})
      end

      ##
      # Delete a set of section entries based on the supplied POST
      # field "section_entry_ids".
      #
      # @since      0.1
      # @permission delete_section_entry
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
            Ramaze::Log.error(e)
            message(:error,lang('section_entries.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('section_entries.success.delete'))
        redirect_referrer
      end
    end  # SectionEntries
  end # Controller
end # Sections
