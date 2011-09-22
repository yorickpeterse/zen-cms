#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper for the users package. Note that this helper is called "Users"
    # rather than "User" as otherwise Ramaze could get confused and load the
    # incorrect helper (as it already comes with a helper named "User").
    #
    # @author Yorick Peterse
    # @since  0.2.8
    #
    module Users
      ##
      # Checks if an access rule is valid and returns it if ithis is the case.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] access_rule_id The ID of the access rule to validate.
      # @return [Users::Model::AccessRule]
      #
      def validate_access_rule(access_rule_id)
        rule = ::Users::Model::AccessRule[access_rule_id]

        if rule.nil?
          message(:error, lang('access_rules.errors.invalid_rule'))
          redirect(::Users::Controller::AccessRules.r(:index))
        else
          return rule
        end
      end

      ##
      # Checks if a user group is valid and returns it if this is the case.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] user_group_id The ID of the user group to validate.
      # @return [Users::Model::UserGroup]
      #
      def validate_user_group(user_group_id)
        group = ::Users::Model::UserGroup[user_group_id]

        if group.nil?
          message(:error, lang('user_groups.errors.invalid_group'))
          redirect(::Users::Controller::UserGroups.r(:index))
        else
          return group
        end
      end

      ##
      # Validates a user and returns the object if it's a valid user.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      # @param  [Fixnum] user_id The ID of the user to validate.
      # @return [Users::Model::User]
      #
      def validate_user(user_id)
        user = ::Users::Model::User[user_id]

        if user.nil?
          message(:error, lang('users.errors.invalid_user'))
          redirect(::Users::Controller::Users.r(:index))
        else
          return user
        end
      end

      ##
      # Updates the permissions for a user or a user group.
      #
      # @example
      #  update_permissions(:user_id, 5, [:show_user], [:edit_user])
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [Symbol] column The name of the column to use in the permissions
      #  table. Can either be :user_id or :user_group_id.
      # @param  [Fixnum] id The primary value of the column attribute.
      # @param  [Array] new_perms An array of new permissions.
      # @param  [Array] old_perms An array of existing permissions.
      #
      def update_permissions(column, id, new_perms = [], old_perms = [])
        add_perms = []
        rm_perms  = []

        # Insert all the new permissions
        new_perms.each do |perm|
          if !old_perms.include?(perm)
            add_perms << {column => id, :permission => perm}
          end
        end

        # Remove permissions if they weren't checked
        old_perms.each do |perm|
          if !new_perms.include?(perm)
            rm_perms << {column => id, :permission => perm}
          end
        end

        ::Users::Model::Permission.insert_multiple(add_perms)
        ::Users::Model::Permission.filter(
          column      => rm_perms.map { |p| p[column] },
          :permission => rm_perms.map { |p| p[:permission] }
        ).delete

        session[:super_group] = nil
        session[:permissions] = nil
      end
    end # Users
  end # Helper
end # Ramaze
