module Users
  module Controllers
    ##
    # Controller for managing access rules. Each access rule can be used
    # to specify whether or not a user can edit or create something.
    # 
    # The following permissions are available:
    #
    # * create
    # * read
    # * update
    # * delete
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class AccessRules < Zen::Controllers::AdminController
      map '/admin/access_rules'
      
      trait :extension_identifier => 'com.zen.users'
      include ::Users::Models
      
      before_all do
        csrf_protection :save, :delete do
          respond(@zen_general_lang.errors[:csrf], 403)
        end
      end
      
      ##
      # Load our language packs, set the form URLs and define our page title.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = '/admin/access_rules/save'
        @form_delete_url = '/admin/access_rules/delete'
        @rules_lang      = Zen::Language.load 'access_rules'
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @rules_lang.titles.key? method 
            @page_title = @rules_lang.titles[method]
          end
        end
        
        require_js 'users/access_rules'
      end
      
      ##
      # Show an overview of all access rules and allow the current user
      # to manage these groups.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs @rules_lang.titles[:index]
        
        @access_rules = AccessRule.all
      end
      
      ##
      # Edit an existing access rule.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def edit id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@rules_lang.titles[:index], "admin/access_rules"), @rules_lang.titles[:edit]
        
        @access_rule = AccessRule[id]
      end
      
      ##
      # Create a new access rule.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs anchor_to(@rules_lang.titles[:index], "admin/access_rules"), @rules_lang.titles[:new]
        
        @access_rule = AccessRule.new
      end
      
      ##
      # Saves or creates a new access rule based on the POST data and a field named "id".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        if !user_authorized?([:create, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post = request.params.dup
       
        post.each do |key, value|
          post.delete(key) if value.empty?
        end

        if post['rule_applies'] == 'div_user_id'
          post['user_group_id'] = nil
        else
          post['user_id'] = nil
        end
        
        post.delete('rule_applies')

        if post["id"] and !post["id"].empty?
          @access_rule = AccessRule[post["id"]]
          save_action = :save
        else
          @access_rule = AccessRule.new
          save_action = :new
        end
        
        flash_success = @rules_lang.success[save_action]
        flash_error   = @rules_lang.errors[save_action]
        
        begin
          @access_rule.update(post)
          notification(:success, @rules_lang.titles[:index], flash_success)
        rescue
          notification(:error, @rules_lang.titles[:index], flash_error)
          
          flash[:form_errors] = @access_rule.errors
        end
        
        if @access_rule.id
          redirect "/admin/access_rules/edit/#{@access_rule.id}"
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete all specified access rules.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        if !request.params["access_rule_ids"] or request.params["access_rule_ids"].empty?
          notification(:error, @rules_lang.titles[:index], @rules_lang.errors[:no_delete])
          redirect_referrer
        end
        
        request.params["access_rule_ids"].each do |id|
          @access_rule = AccessRule[id]
          
          begin
            @access_rule.delete
            notification(:success, @rules_lang.titles[:index], @rules_lang.success[:delete] % id)
          rescue
            notification(:error, @rules_lang.titles[:index], @rules_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end
  end
end
