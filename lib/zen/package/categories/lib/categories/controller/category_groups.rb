module Categories
  module Controller
    ##
    # Category groups can be used to group a number of categories into a single container.
    # These groups are assigned to a section (rather than individual categories). It's
    # important to remember that a section entry can't use a category group until it has
    # been added to a section.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CategoryGroups < Zen::Controller::AdminController
      include ::Categories::Model

      map('/admin/category-groups')

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # The constructor is used to set various options such as the form URLs and load
      # the language pack for the categories module.
      #
      # The following language files are loaded:
      #
      # * category_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @form_save_url   = CategoryGroups.r(:save)
        @form_delete_url = CategoryGroups.r(:delete)

        Zen::Language.load('category_groups')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_s
          @page_title = lang("category_groups.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all existing category groups and allow the user
      # to create new category groups or manage individual categories.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        set_breadcrumbs(lang('category_groups.titles.index'))

        @category_groups = CategoryGroup.all
      end

      ##
      # Edit an existing category group based on the ID specified in the URL.
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        set_breadcrumbs(
          anchor_to(lang('category_groups.titles.index'), CategoryGroups.r(:index)),
          lang('category_groups.titles.edit')
        )

        if flash[:form_data]
          @category_group = flash[:form_data]
        else
          @category_group = CategoryGroup[id]
        end
      end

      ##
      # Create a new category group. This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:create, :read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        set_breadcrumbs(
          anchor_to(lang('category_groups.titles.index'), CategoryGroups.r(:index)),
          lang('category_groups.titles.new')
        )

        @category_group = CategoryGroup.new
      end

      ##
      # Save or create a new category group based on the current POST data.
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        post = request.subset(:id, :name, :description)

        if post['id'] and !post['id'].empty?
          @category_group = CategoryGroup[post['id']]
          save_action     = :save
        else
          @category_group = CategoryGroup.new
          save_action     = :new
        end

        # Set the messages
        flash_success = lang("category_groups.success.#{save_action}")
        flash_error   = lang("category_groups.errors.#{save_action}")

        post.delete('id')

        # Try to run the query
        begin
          @category_group.update(post)
          message(:success, flash_success)
        rescue => e
          message(:error, flash_error)
          Ramaze::Log.error(e.inspect)

          flash[:form_data]   = @category_group
          flash[:form_errors] = @category_group.errors
        end

        if !@category_group.nil? and @category_group.id
          redirect(CategoryGroups.r(:edit, @category_group.id))
        else
          redirect(CategoryGroups.r(:new))
        end
      end

      ##
      # Delete all specified category groups and their categories. In
      # order to delete a number of groups an array of fields, named "category_group_ids"
      # is required. This array will contain all the primary values of each group that
      # has to be deleted.
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end

        post = request.subset(:category_group_ids)

        if !post['category_group_ids'] or post['category_group_ids'].empty?
          message(:error, lang('category_groups.errors.no_delete'))
          redirect(CategoryGroups.r(:index))
        end

        post['category_group_ids'].each do |id|
          begin
            CategoryGroup[id].destroy
            message(:success, lang('category_groups.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('category_groups.errors.delete') % id)
          end
        end

        redirect(CategoryGroups.r(:index))
      end
    end # CategoryGroups
  end # Controller
end # Categories
