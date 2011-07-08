#:nodoc:
module Users
  #:nodoc:
  module Controller
    ##
    # Controller for managing access rules. Each access rule can be used to 
    # specify whether or not a user can edit or create something.
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

      helper :users
      map '/admin/access-rules'

      javascript(
        ['lib/users/access_rules', 'users/access_rules'], 
        :method => [:edit, :new]
      )

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

        @rule_applies_hash = {
          lang('access_rules.labels.user')       => 'div_user_id',
          lang('access_rules.labels.user_group') => 'div_user_group_id'
        }
      end

      ##
      # Hook that's executed before the edit and new method. This hook is used 
      # to pre-process some data used in the form.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      before(:index, :edit, :new) do
        @form_users       = {}
        @form_groups      = {}
        @form_packages    = {}
        @form_controllers = {}

        ::Users::Model::User.select(:id, :name).each do |user|
          @form_users[user.id.to_s] = user.name
        end

        # Build the list of available packages and controllers
        ::Zen::Package::Registered.each do |name, pkg|
          name                      = name.to_s
          @form_packages[name]      = name
          @form_controllers[name] ||= {
            lang('access_rules.labels.all_controllers') => '*'
          }

          pkg.controllers.each do |key, value|
            @form_controllers[name][key] = value.to_s
          end
        end

        ::Users::Model::UserGroup.select(:id, :name).each do |group|
          @form_groups[group.id.to_s] = group.name
        end
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
        require_permissions(:read)

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
        require_permissions(:read, :update)

        set_breadcrumbs(
          AccessRules.a(lang('access_rules.titles.index'), :index),
          lang('access_rules.titles.edit')
        )

        if flash[:form_data]
          @access_rule = flash[:form_data]
        else
          @access_rule = validate_access_rule(id)
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
        require_permissions(:read, :create)

        set_breadcrumbs(
          AccessRules.a(lang('access_rules.titles.index'), :index),
          lang('access_rules.titles.new')
        )

        @access_rule = AccessRule.new
      end

      ##
      # Saves or creates a new access rule based on the POST data and a field 
      # named 'id'.
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

        post = request.subset(
          :id, 
          :package, 
          :read_access, 
          :create_access,
          :update_access, 
          :delete_access,
          :user_id, 
          :user_group_id, 
          :controller, 
          :rule_applies
        )

        if post['rule_applies'] === 'div_user_id'
          post['user_group_id'] = nil
        else
          post['user_id'] = nil
        end

        if post['id'] and !post['id'].empty?
          access_rule = validate_access_rule(post['id'])
          save_action = :save
        else
          access_rule = AccessRule.new
          save_action = :new
        end

        post.delete('rule_applies')
        post.delete('id')

        flash_success = lang("access_rules.success.#{save_action}")
        flash_error   = lang("access_rules.errors.#{save_action}")

        begin
          access_rule.update(post)

          # Flush the existing rules from the session
          session.delete(:access_rules)
          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = access_rule
          flash[:form_errors] = access_rule.errors

          redirect_referrer
        end

        if access_rule.id
          redirect(AccessRules.r(:edit, access_rule.id))
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
        require_permissions(:delete)

        if !request.params['access_rule_ids'] \
        or request.params['access_rule_ids'].empty?
          message(:error, lang('access_rules.errors.no_delete'))
          redirect_referrer
        end

        request.params['access_rule_ids'].each do |id|
          @access_rule = AccessRule[id]

          begin
            @access_rule.delete
            session.delete(:access_rules)
            message(:success, lang('access_rules.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('access_rules.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # AccessRules
  end # Controller
end # Users
