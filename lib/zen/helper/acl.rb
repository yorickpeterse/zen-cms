#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    #
    module ACL
      def user_authorized?(required)
        if session[:super_group].nil? or session[:permissions].nil?
          get_permissions
        end

        super_group, permissions = session[:super_group], session[:permissions]

        required.each do |req|
          req = req.to_s

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
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Array] *args An array of permissions that are required.
      #
      def require_permissions(*args)
        if !user_authorized?(args)
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
      end

      def get_permissions
        super_group = false
        perms       = session[:user].permissions.map { |p| p.permission }
        group_ids   = []

        session[:user].user_groups.each do |group|
          super_group = true if group.super_group === true
          group_ids << group.id
        end

        ::Users::Model::Permission \
          .filter(:user_group_id => group_ids) \
          .each { |p| perms << p.permission }

        perms = perms.uniq

        session[:super_group] = super_group
        session[:permissions] = perms
      end
    end # ACL
  end # Helper
end # Ramaze
