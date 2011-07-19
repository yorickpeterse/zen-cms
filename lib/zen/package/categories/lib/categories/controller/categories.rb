#:nodoc:
module Categories
  #:nodoc:
  module Controller
    ##
    # Categories can be seen as "tags" for your section entries. They describe 
    # the type of entry just like tags except that categories generally cover 
    # larger elements. When adding a new entry categories aren't required so 
    # you're free to ignore them if you don't need them.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Categories < Zen::Controller::AdminController
      include ::Categories::Model

      map '/admin/categories'
      helper :category

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # The constructor is used to set various options such as the form URLs and 
      # load the language pack for the categories module.
      #
      # The following language files are loaded:
      #
      # * categories
      # * category_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        Zen::Language.load('categories')
        Zen::Language.load('category_groups')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_s
          @page_title = lang("categories.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all existing categories and allow the user
      # to create and manage these categories.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @param  [Fixnum] category_group_id The ID of the category group that's 
      # currently being managed by the user.
      # @since  0.1
      #
      def index(category_group_id)
        require_permissions(:read)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('categories.titles.index')
        )

        # Validate the category group
        category_group     = validate_category_group(category_group_id)
        @category_group_id = category_group_id
        @categories        = category_group.categories
      end

      ##
      # Edit an existing category based on the ID specified in the URL.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The category group ID.
      # @param  [Integer] id The ID of the category to edit.
      # @since  0.1
      #
      def edit(category_group_id, id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          CategoryGroups.a(
            lang('category_groups.titles.index'), :index
          ),
          Categories.a(
            lang('categories.titles.index'), :index, category_group_id
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
      # Create a new category.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The ID of the category group.
      # @since  0.1
      #
      def new(category_group_id)
        require_permissions(:read, :create)

        set_breadcrumbs(
          CategoryGroups.a(
            lang('category_groups.titles.index'), :index
          ),
          Categories.a(
            lang('categories.titles.index'), :index, category_group_id
          ),
          lang('categories.titles.new')
        )

        validate_category_group(category_group_id)

        @category_group_id = category_group_id
        @category          = Category.new

        render_view(:form)
      end

      ##
      # Save the changes made to an existing category or create a new one based
      # on the current POST data.
      #
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        require_permissions(:create, :update)

        # Fetch all the required fields
        post = request.subset(
          :id, 
          :parent_id, 
          :name, 
          :description, 
          :slug, 
          :category_group_id
        )

        # Validate the category group
        validate_category_group(post['category_group_id'])

        # Retrieve the category and set the notifications based on if the ID has
        # been specified or not.
        if post['id'] and !post['id'].empty?
          category    = validate_category(post['id'], post['category_group_id'])
          save_action = :save
        else
          category    = Category.new
          save_action = :new
        end

        post.delete('slug') if post['slug'].empty?
        post.delete('id')

        # Set the messages to display
        flash_success = lang("categories.success.#{save_action}")
        flash_error   = lang("categories.errors.#{save_action}")

        # Try to update the category
        begin
          category.update(post)
          message(:success, flash_success)
        rescue
          message(:error, flash_error)

          flash[:form_errors] = category.errors
          flash[:form_data]   = category

          redirect_referrer
        end

        if category.id
          redirect(Categories.r(:edit, post['category_group_id'], category.id))
        else
          redirect(Categories.r(:new, post['category_group_id']))
        end
      end

      ##
      # Delete all specified category groups and their categories. In
      # order to delete a number of groups an array of fields, named 
      # "category_group_ids" is required. This array will contain all the 
      # primary values of each group that has to be deleted.
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

        post = request.subset(:category_ids, :category_group_id)

        # Obviously we'll require some IDs
        if !request.params['category_ids'] \
        or request.params['category_ids'].empty?
          message(:error, lang('categories.errors.no_delete'))
          redirect(Categories.r(:index, post['category_group_id']))
        end

        # Delete each section
        request.params['category_ids'].each do |id|
          begin
            Category[id].destroy
            message(:success, lang('categories.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('categories.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect(Categories.r(:index, post['category_group_id']))
      end
    end # Categories
  end # Controller
end # Categories
