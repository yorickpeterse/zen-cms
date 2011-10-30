module Users
  module Model
    ##
    # Model for managing permissions.
    #
    # @since  0.3
    #
    class Permission < Sequel::Model
      many_to_one :user      , :class => 'Users::Model::User'
      many_to_one :user_group, :class => 'Users::Model::UserGroup'

      ##
      # Validates the model's attributes before saving it.
      #
      # @since  0.3
      #
      def validate
        validates_presence(:permission)

        if self.user_id.nil?
          validates_presence(:user_group_id)
        else
          validates_presence(:user_id)
        end
      end
    end # Permission
  end # Model
end # Users
