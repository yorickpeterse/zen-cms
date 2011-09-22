module Users
  module Model
    ##
    # Model for managing permissions.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    class Permission < Sequel::Model
      many_to_one :user      , :class => 'Users::Model::User'
      many_to_one :user_group, :class => 'Users::Model::UserGroup'

      ##
      # Validates the model's attributes before saving it.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      #
      def validate
        validates_presence(:permission)
      end
    end # Permission
  end # Model
end # Users
