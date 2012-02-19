##
# Package for managing categories and category groups.
#
# ## Controllers
#
# * {Categories::Controller::CategoryGroups}
# * {Categories::Controller::Categories}
#
# ## Helpers
#
# * {Ramaze::Helper::Category}
# * {Ramaze::Helper::CategoryFrontend}
#
# ## Models
#
# * {Categories::Model::CategoryGroup}
# * {Categories::Model::Category}
#
# @since  0.1
#
module Categories
  #:nodoc:
  module Controller
    ##
    # Category groups are containers for individual categories. A category group
    # can be assigned to multiple sections and it can have multiple categories.
    #
    # In order to manage a category group you must first go to the overview that
    # shows all existing group (or a message telling you no groups have been
    # added if this is the case). This can be done by clicking the "Categories"
    # button in the top navigation menu or by manually pointing your browser to
    # ``/admin/category-groups``. This overview looks like the image displayed
    # below.
    #
    # ![Category Group Overview](../../_static/categories/category_groups.png)
    #
    # Editing an existing group can be done by clicking on the name of a group
    # while managing the categories of a group is done by clicking the link
    # "Manage Categories" (the text may differ depending on the language you're
    # using). If you want to delete a number of groups all you'd have to do is
    # clicking the checkboxes of each row you'd wish to delete followed by
    # pressing the button "Delete selected groups". This will trigger an action
    # that removes all category groups and the categories that belong to those
    # groups.
    #
    # ## Adding/Editing Groups
    #
    # By clicking the name of a group or the "Add group" button you can edit an
    # existing group or create a new one. The form used to manage such a group
    # looks like the one in the image below.
    #
    # ![New Category Group](../../_static/categories/new_category_group.png)
    #
    # In this form you can set the following fields:
    #
    # * **Name**: the name of the category group. It can be any name in any
    #   format as long as it's not longer than 255 characters.
    # * **Description**: the description of the category group. While not
    #   required it can be used to make it easier to remember that purpose a
    #   category group has.
    #
    # ## Used Permissions
    #
    # * show_category_group
    # * edit_category_group
    # * new_category_group
    # * delete_category_group
    #
    # @since  0.1
    # @map    /admin/category-groups
    #
    class CategoryGroups < Zen::Controller::AdminController
      helper :category
      map    '/admin/category-groups'
      title  'category_groups.titles.%s'

      csrf_protection :save, :delete

      autosave Model::CategoryGroup,
        Model::CategoryGroup::COLUMNS,
        :edit_category_group

      ##
      # Show an overview of all existing category groups and allow the user
      # to create new category groups or manage individual categories.
      #
      # @since      0.1
      # @permission show_category_group
      #
      def index
        authorize_user!(:show_category_group)

        set_breadcrumbs(lang('category_groups.titles.index'))

        @category_groups = search do |query|
          ::Categories::Model::CategoryGroup.search(query).order(:id.asc)
        end

        @category_groups ||= ::Categories::Model::CategoryGroup.order(:id.asc)
        @category_groups   = paginate(@category_groups)
      end

      ##
      # Allows a user to edit an existing category group.
      #
      # @since      0.1
      # @param      [Fixnum] id The ID of the category group to edit.
      # @permission edit_category_group
      #
      def edit(id)
        authorize_user!(:edit_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.edit')
        )

        @category_group = flash[:form_data] || validate_category_group(id)

        render_view(:form)
      end

      ##
      # Allows the user to add a new category group.
      #
      # @since  0.1
      # @permission new_category_group
      #
      def new
        authorize_user!(:new_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.new')
        )

        if flash[:form_data]
          @category_group = flash[:form_data]
        else
          @category_group = ::Categories::Model::CategoryGroup.new
        end

        render_view(:form)
      end

      ##
      # Creates a new category or updates the data of an existing category. If a
      # category ID is specified (in the POST key "id") that existing category
      # will be updated, otherwise a new one will be created.
      #
      # @since      0.1
      # @permission edit_category_group (when editing a group)
      # @permission new_category_group (when creating a group)
      #
      def save
        post = post_fields(*Model::CategoryGroup::COLUMNS)
        id   = request.params['id']

        # Get/create the group and set the event names.
        if id and !id.empty?
          authorize_user!(:edit_category_group)

          category_group = validate_category_group(id)
          save_action    = :save
        else
          authorize_user!(:new_category_group)

          category_group = ::Categories::Model::CategoryGroup.new
          save_action    = :new
        end

        success = lang("category_groups.success.#{save_action}")
        error   = lang("category_groups.errors.#{save_action}")

        # Set the values, call the events and try to save the category group.
        begin
          post.each { |k, v| category_group.send("#{k}=", v) }

          category_group.save
        rescue => e
          message(:error, error)
          Ramaze::Log.error(e)

          flash[:form_data]   = category_group
          flash[:form_errors] = category_group.errors

          redirect_referrer
        end

        message(:success, success)
        redirect(CategoryGroups.r(:edit, category_group.id))
      end

      ##
      # Deletes a number of category groups. The IDs of these groups should be
      # specified in the POST array "category_group_ids".
      #
      # @since      0.1
      # @permission delete_category_group
      #
      def delete
        authorize_user!(:delete_category_group)

        post = post_fields(:category_group_ids)

        if post['category_group_ids'].nil? or post['category_group_ids'].empty?
          message(:error, lang('category_groups.errors.no_delete'))
          redirect(CategoryGroups.r(:index))
        end

        post['category_group_ids'].each do |id|
          group = ::Categories::Model::CategoryGroup[id]

          next if group.nil?

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('category_groups.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('category_groups.success.delete'))
        redirect_referrer
      end
    end # CategoryGroups
  end # Controller
end # Categories
