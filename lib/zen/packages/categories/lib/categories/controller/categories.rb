module Categories
  module Controllers
    ##
    # Categories can be seen as "tags" for your section entries. They describe the
    # type of entry just like tags except that categories generally cover larger elements.
    # When adding a new entry categories aren't required so you're free to ignore them if you
    # don't need them.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Categories < Zen::Controllers::AdminController
      map '/admin/categories'
      
      trait :extension_identifier => 'com.zen.categories'
      
      include ::Categories::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 403)
        end
      end
      
      ##
      # The constructor is used to set various options such as the form URLs and load
      # the language pack for the categories module.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = '/admin/categories/save'
        @form_delete_url = '/admin/categories/delete'
        @categories_lang = Zen::Language.load 'categories'
        @groups_lang     = Zen::Language.load 'category_groups'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @categories_lang.titles.key? method
            @page_title = @categories_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all existing categories and allow the user
      # to create and manage these categories.
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The ID of the category group that's currently
      # being managed by the user.
      # @since  0.1
      #
      def index category_group_id
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/category_groups/"),
          @categories_lang.titles[:index]
                              
        @category_group_id = category_group_id
        @categories        = CategoryGroup[category_group_id].categories
      end
      
      ##
      # Edit an existing category based on the ID specified in the URL.
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The category group ID.
      # @param  [Integer] id The ID of the category to edit.
      # @since  0.1
      #
      def edit category_group_id, id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/category_groups/"),
          anchor_to(@categories_lang.titles[:index], "admin/categories/index/#{category_group_id}"),
          @categories_lang.titles[:edit]
          
        @category_group_id = category_group_id
        @category          = Category[id]
      end
      
      ##
      # Create a new category.
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The ID of the category group.
      # @since  0.1
      #
      def new category_group_id
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/category_groups/"),
          anchor_to(@categories_lang.titles[:index], "admin/categories/index/#{category_group_id}"),
          @categories_lang.titles[:new]
          
        @category_group_id = category_group_id
        @category          = Category.new
      end

      ##
      # Save the changes made to an existing category or create a new one based
      # on the current POST data.
      #
      # @author Yorick Peterse
      # @since  0.1
      #    
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post              = request.params.dup
        category_group_id = post["category_group_id"]
        
        # Remove all empty values
        post.each do |key, value|
          post.delete(key) if value.empty?
        end
        
        post.delete("parent_id") if post["parent_id"] == '--'
        
        # Retrieve the category and set the notifications based on if the ID has
        # been specified or not.
        if post["id"] and !post["id"].empty?
          @category   = Category[post["id"]]
          save_action = :save
        else
          @category   = Category.new
          save_action = :new
        end
        
        flash_success = @categories_lang.success[save_action]
        flash_error   = @categories_lang.errors[save_action]
        
        # Try to update the category
        begin
          @category.update(post)
          notification(:success, @categories_lang.titles[:index], flash_success)
        rescue
          notification(:error, @categories_lang.titles[:index], flash_error)
          flash[:form_errors] = @categories_lang.errors
        end
        
        if @category.id
          redirect "/admin/categories/edit/#{category_group_id}/#{@category.id}"
        else  
          redirect "/admin/categories/new/#{category_group_id}"
        end
      end
      
      ##
      # Delete all specified category groups and their categories. In
      # order to delete a number of groups an array of fields, named "category_group_ids"
      # is required. This array will contain all the primary values of each group that
      # has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post              = request.params.dup
        category_group_id = post["category_group_id"]
        
        # Obviously we'll require some IDs
        if !request.params["category_ids"] or request.params["category_ids"].empty?
          notification(:error, @categories_lang.titles[:index], @categories_lang.errors[:no_delete])
          redirect "/admin/categories/index/#{category_group_id}"
        end
        
        # Delete each section
        request.params["category_ids"].each do |id|
          @category = Category[id]
          
          begin
            @category.delete
            notification(:success, @categories_lang.titles[:index], @categories_lang.success[:delete] % id)
          rescue
            notification(:error, @categories_lang.titles[:index], @categories_lang.errors[:delete] % id)
          end
        end
        
        redirect "/admin/categories/index/#{category_group_id}"
      end
    end
  end
end
