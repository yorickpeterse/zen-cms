module Categories
  #:nodoc:
  module Controller
    ##
    # Categories are data containers that work similar to tags. Categories can
    # be used to group section entries that share similar topics together. A
    # category is always related to a category group and thus you must first
    # create such a group before you can add individual categories. Read the
    # chapter about {Categories::Controller::CategoryGroups Category groups} for
    # more information.
    #
    # In order to manage categories you must first navigate to the category
    # groups overview. In this overview you can click the link "Manage
    # categories" of a certain group to add, edit or remove categories. Once
    # you've reached the categories overview you'll be presented with an
    # overview that looks like the following image:
    #
    # ![Categories Overview](../../_static/categories/categories.png)
    #
    # ## Adding/Editing Categories
    #
    # Editing a category can be done by clicking on the name of that category.
    # If you want to create a new category instead you should click the button
    # "Add category". In both cases you'll end up with the following form:
    #
    # ![New Category](../../_static/categories/new_category.png)
    #
    # In this form you can specify the following fields:
    #
    # * **Name** (required): the name of the category. This name can be anything
    #   and there's no restriction to it's format. An example of such a name
    #   would be "Code" or "Products".
    # * **Slug**: a URL friendly version of a category name. If no slug is
    #   specified one will be generated based on the category name.
    # * **Parent**: the name of the parent category.
    # * **Description**: a description of the category. While not required it
    #   can help you remember what the category is meant for in case the name
    #   doesn't already make this clear enough.
    #
    # Note that both the name of a category and it's slug can not be longer than
    # 255 characters.
    #
    # ## Used Permissions
    #
    # This controller uses the following permissions:
    #
    # * show_category
    # * edit_category
    # * new_category
    # * delete_category
    #
    # @since  0.1
    # @map    /admin/categories
    #
    class Categories < Zen::Controller::AdminController
      map    '/admin/categories'
      helper :category
      title  'categories.titles.%s'

      csrf_protection :save, :delete

      autosave Model::Category,
        Model::Category::COLUMNS,
        'categories.success.save',
        'categories.errors.save',
        'categories.errors.invalid_category'

      ##
      # Show an overview of all existing categories and allow the user
      # manage these categories.
      #
      # @param  [Fixnum] category_group_id The ID of the category group for
      #  which to retrieve all categories.
      # @since      0.1
      # @permission show_category
      #
      def index(category_group_id)
        authorize_user!(:show_category)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('categories.titles.index')
        )

        # Validate the category group
        category_group     = validate_category_group(category_group_id)
        @category_group_id = category_group_id

        @categories = search do |query|
          ::Categories::Model::Category \
            .search(query) \
            .filter(:category_group_id => category_group_id) \
            .order(:id.asc)
        end

        @categories ||= ::Categories::Model::Category \
          .filter(:category_group_id => category_group_id) \
          .order(:id.asc)

        @categories = paginate(@categories)
      end

      ##
      # Allows the user to create a new category.
      #
      # @param      [Fixnum] category_group_id The ID of the category group.
      # @since      0.1
      # @permission new_category
      #
      def new(category_group_id)
        authorize_user!(:new_category)

        set_breadcrumbs(
          CategoryGroups.a(
            lang('category_groups.titles.index'),
            :index
          ),
          Categories.a(
            lang('categories.titles.index'),
            :index,
            category_group_id
          ),
          lang('categories.titles.new')
        )

        validate_category_group(category_group_id)

        @category_group_id = category_group_id

        if flash[:form_data]
          @category = flash[:form_data]
        else
          @category = ::Categories::Model::Category.new
        end

        render_view(:form)
      end

      ##
      # Edit an existing category based on the ID specified in the URL.
      #
      # @param      [Fixnum] category_group_id The category group ID.
      # @param      [Fixnum] id The ID of the category to edit.
      # @since      0.1
      # @permission edit_category
      #
      def edit(category_group_id, id)
        authorize_user!(:edit_category)

        set_breadcrumbs(
          CategoryGroups.a(
            lang('category_groups.titles.index'),
            :index
          ),
          Categories.a(
            lang('categories.titles.index'),
            :index,
            category_group_id
          ),
          lang('categories.titles.edit')
        )

        validate_category_group(category_group_id)

        @category_group_id = category_group_id

        if flash[:form_data]
          @category = flash[:form_data]
        else
          @category = validate_category(id, category_group_id)
        end

        render_view(:form)
      end

      ##
      # Save the changes made to an existing category or create a new one based
      # on the current POST data.
      #
      # @since      0.1
      # @permission edit_category (when editing a category)
      # @permission new_category (when creating a category)
      #
      def save
        id   = request.params['id']
        post = request.subset(*Model::Category::COLUMNS)

        validate_category_group(post['category_group_id'])

        # Retrieve the category and set the notifications based on if the ID has
        # been specified or not.
        if id and !id.empty?
          authorize_user!(:edit_category)

          category    = validate_category(id, post['category_group_id'])
          save_action = :save
        else
          authorize_user!(:new_category)

          category    = ::Categories::Model::Category.new
          save_action = :new
        end

        success = lang("categories.success.#{save_action}")
        error   = lang("categories.errors.#{save_action}")

        # Try to update the category
        begin
          post.each { |k, v| category.send("#{k}=", v) }

          category.save
        rescue => e
          Ramaze::Log.error(e)
          message(:error, error)

          flash[:form_errors] = category.errors
          flash[:form_data]   = category

          redirect_referrer
        end

        message(:success, success)
        redirect(Categories.r(:edit, category.category_group_id, category.id))
      end

      ##
      # Delete all specified category groups and their categories. In order to
      # delete a number of groups an array of fields, named "category_group_ids"
      # is required. This array will contain all the primary values of each
      # group that has to be deleted.
      #
      # @since      0.1
      # @permission delete_category
      #
      def delete
        authorize_user!(:delete_category)

        post = request.subset(:category_ids)

        # Obviously we'll require some IDs
        if post['category_ids'].nil? or post['category_ids'].empty?
          message(:error, lang('categories.errors.no_delete'))
          redirect_referrer
        end

        # Remove each category and call the event.
        request.params['category_ids'].each do |id|
          category = ::Categories::Model::Category[id]

          next if category.nil?

          begin
            category.destroy
          rescue => e
            Ramaze::Log.error(e)
            message(:error, lang('categories.errors.delete') % id)

            redirect_referrer
          end
        end

        message(:success, lang('categories.success.delete'))
        redirect_referrer
      end
    end # Categories
  end # Controller
end # Categories
