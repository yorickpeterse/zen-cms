#:nodoc:
module Categories
  #:nodoc:
  module Controller
    ##
    # Controller for managing and creating categories. A category is always
    # related to a category group and thus none of the methods in this
    # controller will work without a category group ID being specified in the
    # URL. The only exceptions to this are Categories#save() and
    # Categories#delete() as they require them to be specified in the POST data.
    #
    # ## Used Permissions
    #
    # * show_category
    # * edit_category
    # * new_category
    # * delete_category
    #
    # ## Available Events
    #
    # * new_category
    # * edit_category
    # * delete_category
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Categories < Zen::Controller::AdminController
      map    '/admin/categories'
      helper :category
      title  'categories.titles.%s'

      # Protect Categories#save() and Categories#delete() against CSRF attacks.
      csrf_protection :save, :delete

      ##
      # Show an overview of all existing categories and allow the user
      # manage these categories.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] category_group_id The ID of the category group for
      #  which to retrieve all categories.
      # @since  0.1
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
        @categories        = ::Categories::Model::Category.filter(
          :category_group_id => category_group_id
        )

        @categories = paginate(@categories)
      end

      ##
      # Allows the user to create a new category.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] category_group_id The ID of the category group.
      # @since  0.1
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
      # @author Yorick Peterse
      # @param  [Fixnum] category_group_id The category group ID.
      # @param  [Fixnum] id The ID of the category to edit.
      # @since  0.1
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(
          :id,
          :parent_id,
          :name,
          :description,
          :slug,
          :category_group_id
        )

        validate_category_group(post['category_group_id'])

        # Retrieve the category and set the notifications based on if the ID has
        # been specified or not.
        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_category)

          category    = validate_category(post['id'], post['category_group_id'])
          save_action = :save
          event       = :edit_category
        else
          authorize_user!(:new_category)

          category    = ::Categories::Model::Category.new
          save_action = :new
          event       = :new_category
        end

        post.delete('id')

        success = lang("categories.success.#{save_action}")
        error   = lang("categories.errors.#{save_action}")

        # Try to update the category
        begin
          category.update(post)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_errors] = category.errors
          flash[:form_data]   = category

          redirect_referrer
        end

        Zen::Event.call(event, category)

        message(:success, success)
        redirect(Categories.r(:edit, category.category_group_id, category.id))
      end

      ##
      # Delete all specified category groups and their categories. In order to
      # delete a number of groups an array of fields, named "category_group_ids"
      # is required. This array will contain all the primary values of each
      # group that has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
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
            Ramaze::Log.error(e.inspect)
            message(:error, lang('categories.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_category, category)
        end

        message(:success, lang('categories.success.delete'))
        redirect_referrer
      end
    end # Categories
  end # Controller
end # Categories
