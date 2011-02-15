module Categories
  module Controllers
    ##
    # Category groups can be used to group a number of categories into a single container.
    # These groups are assigned to a section (rather than individual categories). It's
    # important to remember that a section entry can't use a category group until it has
    # been added to a section.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CategoryGroups < Zen::Controllers::AdminController
      include ::Categories::Models

      map '/admin/category_groups'
      trait :extension_identifier => 'com.zen.categories'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(@zen_general_lang.errors[:csrf], 403)
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
        @groups_lang     = Zen::Language.load('category_groups')
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @groups_lang.titles.key? method
            @page_title = @groups_lang.titles[method]
          end
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(@groups_lang.titles[:index])
        
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(anchor_to(@groups_lang.titles[:index], CategoryGroups.r(:index)),
          @groups_lang.titles[:edit])
        
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(anchor_to(@groups_lang.titles[:index], CategoryGroups.r(:index)),
          @groups_lang.titles[:new])
        
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
        
        if post['id'] and !post['id'].empty?
          @category_group = CategoryGroup[post['id'].to_i]
          save_action     = :save
        else
          @category_group = CategoryGroup.new
          save_action     = :new
        end
        
        flash_success = @groups_lang.success[save_action]
        flash_error   = @groups_lang.errors[save_action]
        
        begin
          @category_group.update(post)
          notification(:success, @groups_lang.titles[:index], flash_success)
        rescue
          notification(:error  , @groups_lang.titles[:index], flash_error)

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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        post = request.params.dup
        
        if !post['category_group_ids'] or post['category_group_ids'].empty?
          notification(:error, @groups_lang.titles[:index], @groups_lang.errors[:no_delete])
          redirect(CategoryGroups.r(:index))
        end
        
        post['category_group_ids'].each do |id|
          begin
            CategoryGroup[id.to_i].destroy
            notification(:success, @groups_lang.titles[:index], @groups_lang.success[:delete])
          rescue
            notification(:error  , @groups_lang.titles[:index], @groups_lang.errors[:delete] % id)
          end
        end
        
        redirect(CategoryGroups.r(:index))
      end
    end
  end
end
