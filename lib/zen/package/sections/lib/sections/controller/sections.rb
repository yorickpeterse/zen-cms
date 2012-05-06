##
# Package for managing sections and section entries.
#
# ## Controllers
#
# * {Sections::Controller::Sections}
# * {Sections::Controller::SectionEntries}
# * {Sections::Controller::Revisions}
#
# ## Helpers
#
# * {Ramaze::Helper::Section}
# * {Ramaze::Helper::SectionFrontend}
# * {Ramaze::Helper::Revision}
#
# ## Models
#
# * {Sections::Model::Section}
# * {Sections::Model::SectionEntry}
# * {Sections::Model::SectionEntryStatus}
# * {Sections::Model::Revision}
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
    # Sections can be managed by going to ``/admin/sections``. This page will
    # show an overview of all existing sections as well as a few buttons and
    # links that allow you to edit, create or delete sections as well as
    # managing the entries for each existing section.
    #
    # ![Sections](../../images/sections/sections.png)
    #
    # ## Creating/Editing Sections
    #
    # Creating a new section can be done by clicking the button "Add section"
    # while editing a section can be done by clicking the name of a section. In
    # both cases you'll end up with a form that looks like the one in the images
    # below.
    #
    # ![General](../../images/sections/edit_section_general.png)
    # ![Comments](../../images/sections/edit_section_comments.png)
    # ![Groups](../../images/sections/edit_section_groups.png)
    #
    # In this form you can specify the following fields:
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
    #             <td>Name</td>
    #             <td>Yes</td>
    #             <td>255</td>
    #             <td>The name of the section.</td>
    #         </tr>
    #         <tr>
    #             <td>Slug</td>
    #             <td>No</td>
    #             <td>255</td>
    #             <td>
    #                 A URL friendly version of the section name. If no value is
    #                 specified one will be generated based on the section name.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Description</td>
    #             <td>No</td>
    #             <td>Unlimited</td>
    #             <td>A description of the section.</td>
    #         </tr>
    #         <tr>
    #             <td>Allow comments</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>
    #                 Whether or not users can submit comments for this
    #                 section's entries.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Comments require an account</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>
    #                 When set users are required to be logged in in order to
    #                 submit comments.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Moderate comments</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>
    #                 Comments have to be approved before they'll be displayed.
    #             </td>
    #         </tr>
    #         <tr>
    #             <td>Comment format</td>
    #             <td>Yes</td>
    #             <td></td>
    #             <td>The markup format to use for comments.</td>
    #         </tr>
    #         <tr>
    #             <td>Custom field groups</td>
    #             <td></td>
    #             <td></td>
    #             <td>The custom field groups to assign to the section.</td>
    #         </tr>
    #         <tr>
    #             <td>Category groups</td>
    #             <td></td>
    #             <td></td>
    #             <td>The category groups to assign to the section.</td>
    #         </tr>
    #     </tbody>
    # </table>
    #
    # ## Used Permissions
    #
    # * show_section
    # * new_section
    # * edit_section
    # * delete_section
    #
    # @since  0.1
    # @map    /admin/sections
    #
    class Sections < Zen::Controller::AdminController
      map    '/admin/sections'
      helper :section
      title  'sections.titles.%s'

      csrf_protection  :save, :delete
      load_asset_group :tabs, [:edit, :new]

      autosave Model::Section, Model::Section::COLUMNS, :edit_section

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

        @section = validate_section(id)
        @section.set(flash[:form_data]) if flash[:form_data]

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

        @section = Model::Section.new
        @section.set(flash[:form_data]) if flash[:form_data]

        render_view(:form)
      end

      ##
      # Saves any changes made to an existing section or creates a new one.
      #
      # @since      0.1
      # @permission new_section (when creating a section)
      # @permission edit_section (when editing a section)
      #
      def save
        post = post_fields(*Model::Section::COLUMNS)
        id   = request.params['id']

        if id and !id.empty?
          authorize_user!(:edit_section)

          section     = validate_section(id)
          save_action = :save
        else
          authorize_user!(:new_section)

          section     = ::Sections::Model::Section.new
          save_action = :new
        end

        success = lang("sections.success.#{save_action}")
        error   = lang("sections.errors.#{save_action}")

        post['custom_field_group_pks'] ||= []
        post['category_group_pks']     ||= []

        begin
          section.set(post)
          section.save

          if save_action == :new
            section.custom_field_group_pks = post['custom_field_group_pks']
            section.category_group_pks     = post['category_group_pks']
          end
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_data]   = post
          flash[:form_errors] = section.errors

          redirect_referrer
        end

        message(:success, success)
        redirect(Sections.r(:edit, section.id))
      end

      ##
      # Deletes a number of sections and all the related data. These sections
      # should be specified in the POST array "section_ids[]".
      #
      # @since      0.1
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

          begin
            section.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('sections.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('sections.success.delete'))
        redirect_referrer
      end
    end # Sections
  end # Controller
end # Sections
