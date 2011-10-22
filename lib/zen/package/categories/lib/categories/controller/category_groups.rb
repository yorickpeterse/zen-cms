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
# @author Yorick Peterse
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
    # ## Events
    #
    # All available events receive an instance of
    # {Categories::Model::CategoyGroup}. However, the
    # ``after_delete_category_group`` event will receive an instance that has
    # already been removed from the database. This means that you can not make
    # changes to the object and call ``#save()``.
    #
    # Example of logging when a new category group is created:
    #
    #     Zen::Event.listen(:after_new_category_group) do |group|
    #       Ramaze::Log.info("New category: \"#{group.name}\"")
    #     end
    #
    # Maybe you want to automatically add a category group to a section:
    #
    #     Zen::Event.listen(:after_new_category_group) do |group|
    #       section = Sections::Model::Section[5]
    #
    #       begin
    #         section.add_category_group(group)
    #       rescue => e
    #         Ramaze::Log.error(e.inspect)
    #       end
    #     end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/category-groups
    # @event  before_new_category_group
    # @event  after_new_category_group
    # @event  before_edit_category_group
    # @event  after_edit_category_group
    # @event  before_delete_category_group
    # @event  after_delete_category_group
    #
    class CategoryGroups < Zen::Controller::AdminController
      helper :category
      map    '/admin/category-groups'
      title  'category_groups.titles.%s'

      # Protects CategoryGroups#save() and CategoryGroups#delete() against CSRF
      # attacks.
      csrf_protection :save, :delete

      ##
      # Show an overview of all existing category groups and allow the user
      # to create new category groups or manage individual categories.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_category_group
      #
      def index
        authorize_user!(:show_category_group)

        set_breadcrumbs(lang('category_groups.titles.index'))

        @category_groups = search do |query|
          ::Categories::Model::CategoryGroup.search(query)
        end

        @category_groups ||= ::Categories::Model::CategoryGroup
        @category_groups   = paginate(@category_groups)
      end

      ##
      # Allows a user to edit an existing category group.
      #
      # @author     Yorick Peterse
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
      # @author Yorick Peterse
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
      # @author     Yorick Peterse
      # @since      0.1
      # @permission edit_category_group (when editing a group)
      # @permission new_category_group (when creating a group)
      # @event      before_new_category_group
      # @event      after_new_category_group
      # @event      before_edit_category_group
      # @event      after_edit_category_group
      #
      def save
        post = request.subset(:id, :name, :description)

        # Get/create the group and set the event names.
        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_category_group)

          category_group = validate_category_group(post['id'])
          save_action    = :save
          before_event   = :before_edit_category_group
          after_event    = :after_edit_category_group
        else
          authorize_user!(:new_category_group)

          category_group = ::Categories::Model::CategoryGroup.new
          save_action    = :new
          before_event   = :before_new_category_group
          after_event    = :after_new_category_group
        end

        success = lang("category_groups.success.#{save_action}")
        error   = lang("category_groups.errors.#{save_action}")

        post.delete('id')

        # Set the values, call the events and try to save the category group.
        begin
          post.each { |k, v| category_group.send("#{k}=", v) }
          Zen::Event.call(before_event, category_group)

          category_group.save
        rescue => e
          message(:error, error)
          Ramaze::Log.error(e.inspect)

          flash[:form_data]   = category_group
          flash[:form_errors] = category_group.errors

          redirect_referrer
        end

        Zen::Event.call(after_event, category_group)

        message(:success, success)
        redirect(CategoryGroups.r(:edit, category_group.id))
      end

      ##
      # Deletes a number of category groups. The IDs of these groups should be
      # specified in the POST array "category_group_ids".
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission delete_category_group
      # @event      before_delete_category_group
      # @event      after_delete_category_group
      #
      def delete
        authorize_user!(:delete_category_group)

        post = request.subset(:category_group_ids)

        if post['category_group_ids'].nil? or post['category_group_ids'].empty?
          message(:error, lang('category_groups.errors.no_delete'))
          redirect(CategoryGroups.r(:index))
        end

        post['category_group_ids'].each do |id|
          group = ::Categories::Model::CategoryGroup[id]

          next if group.nil?

          Zen::Event.call(:before_delete_category_group, group)

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('category_groups.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:after_delete_category_group, group)
        end

        message(:success, lang('category_groups.success.delete'))
        redirect_referrer
      end
    end # CategoryGroups
  end # Controller
end # Categories
