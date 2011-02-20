module Users
  module Models
    ##
    # Model that represents a single access rule. This model has the following
    # relations:
    #
    # * users (many to one)
    # * user groups (many to one)
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class AccessRule < Sequel::Model
      many_to_one :user      , :class => "Users::Models::User"
      many_to_one :user_group, :class => "Users::Models::UserGroup"
      
      ##
      # Validation rules used when creating or updating an access rule.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence        [:extension, :create_access, :read_access, :update_access, :delete_access]
        validates_type TrueClass, [:create_access, :read_access, :update_access, :delete_access]
      end
    end
  end
end
