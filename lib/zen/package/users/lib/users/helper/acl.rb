#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # The ACL helper makes it easy for developers to allow or deny access to
    # certain resources based on the permissions of a user. This helper is
    # loaded by default and provides the following two methods:
    #
    # * user_authorized?()
    # * authorize_user!()
    #
    # ## Example
    #
    #     class Foo < Zen::Controller::AdminController
    #       map '/admin/foo'
    #
    #       def index
    #         authorize_user!(:show_foo)
    #       end
    #     end
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    module ACL
      ##
      # Checks if a user has all the specified permissions and returns a
      # TrueClass or FalseClass based on the results. Note that since Zen 0.3
      # *all* permissions set will be required, you're no longer able to
      # specify a list of which only 1 permission is required.
      #
      # This method is useful for hiding certain elements of a page based on a
      # user's permissions. If you want to deny access to an entire method or
      # class you should use ``Ramaze::Helper::ACL#authorize_user!()`` instead.
      #
      # @example
      #  if user_authorized?(:show_user)
      #    # ...
      #  end
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Array] *required An array of permissions that are required.
      # @return [TrueClass|FalseClass]
      #
      def user_authorized?(*required)
        super_group, permissions = get_permissions

        required.each do |req|
          req = req.to_sym if req.respond_to?(:to_sym)

          if !permissions.include?(req) and super_group === false
            return false
          end
        end

        return true
      end

      ##
      # Method that checks if the user has the given permissions. If this isn't
      # the case an error message is displayed and the user won't be able to
      # access the page.
      #
      # @example
      #  authorize_user!(:edit_user)
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Array] *args An array of permissions that are required.
      #
      def authorize_user!(*args)
        if !user_authorized?(args)
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
      end

      private

      ##
      # Retrieves all the permissions of the currently logged in user and stores
      # them in the session.
      #
      # @author Yorick Peterse
      # @since  0.3
      # @return [Array] An array where the first item is a TrueClass or
      #  FalseClass that indicates if the user is member of a super group or
      #  not. The second item is an array of all the user's permissions (each
      #  permission is a symbol).
      #
      def get_permissions
        if !session[:super_group].nil? or !session[:permissions].nil?
          return [session[:super_group], session[:permissions]]
        end

        super_group = false
        perms       = user.permissions.map { |p| p.permission }
        group_ids   = []

        user.user_groups.each do |group|
          super_group = true if group.super_group === true
          group_ids << group.id
        end

        ::Users::Model::Permission \
          .filter(:user_group_id => group_ids) \
          .each { |p| perms << p.permission.to_sym }

        perms = perms.uniq

        session[:super_group] = super_group
        session[:permissions] = perms

        return [session[:super_group], session[:permissions]]
      end
    end # ACL
  end # Helper
end # Ramaze
