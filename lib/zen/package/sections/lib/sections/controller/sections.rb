##
# Package for managing sections and section entries.
#
# ## Controllers
#
# * {Sections::Controller::Sections}
# * {Sections::Controller::SectionEntries}
#
# ## Helpers
#
# * {Ramaze::Helper::Section}
# * {Ramaze::Helper::SectionFrontend}
#
# ## Models
#
# * {Sections::Model::Section}
# * {Sections::Model::SectionEntry}
# * {Sections::Model::SectionEntryStatus}
#
module Sections
  #:nodoc:
  module Controller
    ##
    # Sections are data containers with a specific purpose. For example, you
    # might have a "Blog" or "Pages" section each with it's own entries,
    # categories, custom fields and so on. A section and it's entries glue all
    # the other data types (such as those mentioned earlier) together to form
    # the content displayed on your website.
    #
    # Sections can be managed by going to ``/admin``. This page will show an
    # overview of all existing sections as well as a few buttons and links that
    # allow you to edit, create or delete sections as well as managing the
    # entries for each existing section.
    #
    # ![Sections](../../_static/sections/sections.png)
    #
    # ## Creating/Editing Sections
    #
    # Creating a new section can be done by clicking the button "Add section"
    # while editing a section can be done by clicking the name of a section. In
    # both cases you'll end up with a form that looks like the one in the images
    # below.
    #
    # ![General](../../_static/sections/edit_section_general.png)
    # ![Comments](../../_static/sections/edit_section_comments.png)
    # ![Groups](../../_static/sections/edit_section_groups.png)
    #
    # In this form you can specify the following fields:
    #
    # * **Name** (required): the name of the section.
    # * **Slug**: a URL friendly version of the section name. If no slug is
    #   specified one will be generated automatically.
    # * **Description**: a description of the section to help clarify it's
    #   purpose.
    # * **Allow comments** (required): whether or not users can submit comments
    #   for entries assigned to the section.
    # * **Comments require an account** (required): when set to "Yes" a user has
    #   to be logged in in order to post a comment.
    # * **Moderate comments** (required): when enabled a comment first has to be
    #   approved before it's displayed. This option is disabled by default.
    # * **Comment format** (required): the format comments are posted in such as
    #   Markdown or plain text.
    # * **Custom field groups**: all the custom field groups to assign to the
    #   section. These groups can then be used by all the entries in the
    #   section.
    # * **Category groups**: all the category groups that should be available to
    #   the section entries of this section.
    #
    # Note that the name and the slug of a section can not be longer than 255
    # characters.
    #
    # ## Used Permissions
    #
    # * show_section
    # * new_section
    # * edit_section
    # * delete_section
    #
    # ## Events
    #
    # All events in this controller receive an instance of
    # {Sections::Model::Section}. The event ``after_delete_section`` receives an
    # instance that has already been removed, thus you can't make any changes to
    # it and save those in the database.
    #
    # Example of creating a dummy section entry:
    #
    #     Zen::Event.listen(:new_section) do |section|
    #       section.add_section_entry(:title   => 'My Entry', :user_id => user.id)
    #     end
    #
    # @since  0.1
    # @map    /admin/sections
    # @event  before_new_section
    # @event  after_new_section
    # @event  before_edit_section
    # @event  after_edit_section
    # @event  before_delete_section
    # @event  after_delete_section
    #
    class Sections < Zen::Controller::AdminController
      map    '/admin/sections'
      helper :section
      title  'sections.titles.%s'

      csrf_protection  :save, :delete
      load_asset_group :tabs, [:edit, :new]

      # Hook that is executed before Sections#index(), Sections#new() and
      # Sections#edit().
      before(:index, :new, :edit) do
        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }

        @custom_field_group_pk_hash = ::CustomFields::Model::CustomFieldGroup \
          .pk_hash(:name).invert

        @category_group_pk_hash = ::Categories::Model::CategoryGroup \
          .pk_hash(:name).invert
      end

      ##
      # Show an overview of all existing sections. Using this overview a user
      # can manage an existing section, delete it or create a new one.
      #
      # @since      0.1
      # @permission show_section
      #
      def index
        authorize_user!(:show_section)

        set_breadcrumbs(lang('sections.titles.index'))

        @sections = search do |query|
          ::Sections::Model::Section.search(query).order(:id.asc)
        end

        @sections ||= ::Sections::Model::Section.order(:id.asc)
        @sections   = paginate(@sections)
      end

      ##
      # Show a form that lets the user edit an existing section.
      #
      # @param      [Fixnum] id The ID of the section to edit.
      # @since      0.1
      # @permission edit_section
      #
      def edit(id)
        authorize_user!(:edit_section)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @section = flash[:form_data] || validate_section(id)

        render_view(:form)
      end

      ##
      # Show a form that lets the user create a new section.
      #
      # @since      0.1
      # @permission new_section
      #
      def new
        authorize_user!(:new_section)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @section = flash[:form_data] || ::Sections::Model::Section.new

        render_view(:form)
      end

      ##
      # Saves any changes made to an existing section or creates a new one.
      #
      # @since      0.1
      # @event      before_new_section
      # @event      after_new_section
      # @event      before_edit_section
      # @event      ater_edit_section
      # @permission new_section (when creating a section)
      # @permission edit_section (when editing a section)
      #
      def save
        post = request.subset(
          :id,
          :name,
          :slug,
          :description,
          :comment_allow,
          :comment_require_account,
          :comment_moderate,
          :comment_format,
          :custom_field_group_pks,
          :category_group_pks
        )

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_section)

          section      = validate_section(post['id'])
          save_action  = :save
          before_event = :before_edit_section
          after_event  = :after_edit_section
        else
          authorize_user!(:new_section)

          section      = ::Sections::Model::Section.new
          save_action  = :new
          before_event = :before_new_section
          after_event  = :after_new_section
        end

        success = lang("sections.success.#{save_action}")
        error   = lang("sections.errors.#{save_action}")

        post['custom_field_group_pks'] ||= []
        post['category_group_pks']     ||= []

        post.delete('id')

        begin
          post.each { |k, v| section.send("#{k}=", v) }
          Zen::Event.call(before_event, section)

          section.save

          if save_action == :new
            section.custom_field_group_pks = post['custom_field_group_pks']
            section.category_group_pks     = post['category_group_pks']
          end
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = section
          flash[:form_errors] = section.errors

          redirect_referrer
        end

        Zen::Event.call(after_event, section)

        message(:success, success)
        redirect(Sections.r(:edit, section.id))
      end

      ##
      # Deletes a number of sections and all the related data. These sections
      # should be specified in the POST array "section_ids[]".
      #
      # @since      0.1
      # @event      before_delete_section
      # @event      after_delete_section
      # @permission delete_section
      #
      def delete
        authorize_user!(:delete_section)

        if !request.params['section_ids'] \
        or request.params['section_ids'].empty?
          message(:error, lang('sections.errors.no_delete'))
          redirect_referrer
        end

        request.params['section_ids'].each do |id|
          section = ::Sections::Model::Section[id]

          next if section.nil?
          Zen::Event.call(:before_delete_section, section)

          begin
            section.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('sections.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:after_delete_section, section)
        end

        message(:success, lang('sections.success.delete'))
        redirect_referrer
      end
    end # Sections
  end # Controller
end # Sections
