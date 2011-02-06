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
      map '/admin/category_groups'
      
      trait :extension_identifier => 'com.zen.categories'
      
      include ::Categories::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 401)
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
        
        @form_save_url   = '/admin/category_groups/save'
        @form_delete_url = '/admin/category_groups/delete'
        @groups_lang     = Zen::Language.load 'category_groups'
        
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @groups_lang.titles[:index]
        
        @category_groups = CategoryGroup.all
      end
      
      ##
      # Edit an existing category group based on the ID specified in the URL.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/category_groups"),
          @groups_lang.titles[:edit]
        
        @category_group = CategoryGroup[id]
      end
      
      ##
      # Create a new category group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:create, :read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@groups_lang.titles[:index], "admin/category_groups"),
          @groups_lang.titles[:new ]
        
        @category_group = CategoryGroup.new
      end

      ##
      # Save or create a new category group based on the current POST data.
      #
      # @author Yorick Peterse
      # @since  0.1
      #    
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
        
        if post["id"] and !post["id"].empty?
          @category_group = CategoryGroup[post["id"]]
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
          notification(:error, @groups_lang.titles[:index], flash_error)
          flash[:form_errors] = @groups_lang.errors
        end
        
        if @category_group.id
          redirect "/admin/category_groups/edit/#{@category_group.id}"
        else  
          redirect "/admin/cateogry_groups/new"
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
        
        if !request.params["category_group_ids"] or request.params["category_group_ids"].empty?
          notification(:error, @groups_lang.titles[:index], @groups_lang.errors[:no_delete])
          redirect "/admin/category_groups"
        end
        
        request.params["category_group_ids"].each do |id|
          @category_group = CategoryGroup[id]
          
          begin
            @cateogry_group.delete
            notification(:success, @groups_lang.titles[:index], @groups_lang.success[:delete] % id)
          rescue
            notification(:error, @groups_lang.titles[:index], @groups_lang.errors[:delete] % id)
          end
        end
        
        redirect "/admin/category_groups"
      end
    end
  end
end
