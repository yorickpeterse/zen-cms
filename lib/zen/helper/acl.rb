module Ramaze
  module Helper
    ##
    # This helper provides an easy way of working with the ACL system that
    # ships with Zen. Using this helper you can restrict access to methods,
    # view elements and pretty much everything else based on the user's
    # permissions.
    #
    # In order to use the ACL helper you'll need to define a trait named
    # "extension_identifier" in your classes. Once this trait have been set you
    # can use the "user_authorized?" method to verify the permissions of the current user.
    # The first parameter is an array of required permissions,
    # the second a boolean that indicates if either all or just a single permission must be set.
    #
    # For more information about the ACL system you should read the documentation
    # in the ACL controller, Users::Controllers::AccessRules().
    #
    # @author Yorick Peterse
    # @since  0.1
    # @see    Users::Controllers::AccessRules()
    #
    module ACL
      ##
      # Retrieves all permissions for the current user
      # along with the permissions set for all groups the user
      # belongs to. Rather than loading a new instance of the User model
      # we'll retrieve the model from the session variable set by the
      # User helper provided by Ramaze. Doing this saves us a few queries.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [Mixed] returns a hash containing all rules per identifier along
      # with a boolean that indicates if the user is in a super group.
      #
      def extension_permissions
        m             = session[:user]
        user_groups   = m.user_groups
        super_group   = false
        rules         = []
        ordered_rules = {}
        
        user_groups.each do |group|
          rules += group.access_rules
          
          if group.super_group == true
            super_group = true
          end
        end
        
        m.access_rules.each do |rule|
          rules.push(rule)
        end
        
        rules.each do |rule|
          if !ordered_rules.key?(rule.extension)
            ordered_rules[rule.extension] = []
          end
          
          [:create_access, :read_access, :update_access, :delete_access].each do |perm|
            if rule.send(perm) === true or super_group == true
              perm = perm.to_s.gsub!('_access', '').to_sym
              
              if !ordered_rules[rule.extension].include?(perm)
                ordered_rules[rule.extension].push(perm)
              end
            end
          end
        end
        
        return ordered_rules, super_group
      end
      
      ##
      # Checks if the user has the specified permissions for the current
      # extension that was called. Returns true if this is the case and false
      # otherwise.
      #
      # @author Yorick Peterse
      # @param  [Array] reqs Array of permissions that are required.
      # @param  [Boolean] require_all Boolean that specifies that the user
      # should have ALL specified permissios. Setting this to false causes
      # this method to return true if any of the permissions are set for the
      # current user.
      # @return [Boolean]
      #
      def user_authorized?(reqs, require_all = true)
        identifier = ancestral_trait.values_at(:extension_identifier)
        identifier = identifier[0]
        
        if identifier.nil?
          raise "You need to specify an extension identifier"
        end
        
        # Get the ACL list
        rules       = self.extension_permissions
        super_group = rules[1]
        rules       = rules[0]
        
        # Super groups have full access
        if super_group == true
          return true
        end
        
        # Deny access if the identifier is not found
        if !rules.key?(identifier)
          return false
        end
        
        # Verify the permissions
        perms = rules[identifier]
        
        reqs.each do |req|
          if require_all == false and perms.include?(req)
            return true
          elsif !perms.include?(req)
            return false
          end
        end
        
        return true
      end
    end
  end
end
