#:nodoc:
module Users
  #:nodoc:
  module Controller
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
    class AccessRules < Zen::Controller::AdminController
      include ::Users::Model

      map('/admin/access-rules')
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end
      
      ##
      # Load our language packs, set the form URLs and define our page title.
      #
      # This method loads the following language files:
      #
      # * access_rules
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = AccessRules.r(:save)
        @form_delete_url = AccessRules.r(:delete)
        @rules_lang      = Zen::Language.load('access_rules')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("access_rules.titles.#{method}") rescue nil
        end
        
        require_js 'users/access_rules'

        @rule_applies_hash = {
          lang('access_rules.labels.user')       => 'div_user_id', 
          lang('access_rules.labels.user_group') => 'div_user_group_id'
        }
      end
      
      ##
      # Show an overview of all access rules and allow the current user
      # to manage these groups.
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
        
        set_breadcrumbs(lang('access_rules.titles.index'))
        
        @access_rules = AccessRule.all
      end
      
      ##
      # Edit an existing access rule.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the access rule to edit.
      # @since  0.1
      #
      def edit(id)
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('access_rules.titles.index'), AccessRules.r(:index)), 
          lang('access_rules.titles.edit')
        )
        
        if flash[:form_data]
          @access_rule = flash[:form_data]
        else
          @access_rule = AccessRule[id]
        end
      end
      
      ##
      # Create a new access rule.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create§
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        if !user_authorized?([:read, :create])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('access_rules.titles.index'), AccessRules.r(:index)), 
          lang('access_rules.titles.new')
        )
        
        @access_rule = AccessRule.new
      end
      
      ##
      # Saves or creates a new access rule based on the POST data and a field named 'id'.
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
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post = request.params.dup

        if post['rule_applies'] == 'div_user_id'
          post['user_group_id'] = nil
        else
          post['user_id'] = nil
        end
        
        post.delete('rule_applies')

        if post['id'] and !post['id'].empty?
          @access_rule = AccessRule[post['id']]
          save_action = :save
        else
          @access_rule = AccessRule.new
          save_action = :new
        end
        
        flash_success = lang("access_rules.success.#{save_action}")
        flash_error   = lang("access_rules.errors.#{save_action}")
        
        begin
          @access_rule.update(post)
          notification(:success, lang('access_rules.titles.index'), flash_success)
        rescue
          notification(:error, lang('access_rules.titles.index'), flash_error)
          
          flash[:form_data]   = @access_rule
          flash[:form_errors] = @access_rule.errors
        end
        
        if @access_rule.id
          redirect(AccessRules.r(:edit, @access_rule.id))
        else
          redirect_referrer
        end
      end
      
      ##
      # Delete all specified access rules.
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
        
        if !request.params['access_rule_ids'] or request.params['access_rule_ids'].empty?
          notification(
            :error, 
            lang('access_rules.titles.index'), 
            lang('access_rules.errors.no_delete')
          )

          redirect_referrer
        end
        
        request.params['access_rule_ids'].each do |id|
          @access_rule = AccessRule[id]
          
          begin
            @access_rule.delete
            notification(
              :success, 
              lang('access_rules.titles.index'), 
              lang('access_rules.success.delete')
            )
          rescue
            notification(
              :error, 
              lang('access_rules.titles.index'), 
              lang('access_rules.errors.delete') % id
            )
          end
        end
        
        redirect_referrer
      end
    end
  end
end
