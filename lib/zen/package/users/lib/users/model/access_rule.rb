#:nodoc:
module Users
  #:nodoc:
  module Model
    ##
    # Model that represents a single access rule.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class AccessRule < Sequel::Model
      many_to_one :user      , :class => "Users::Model::User"
      many_to_one :user_group, :class => "Users::Model::UserGroup"

      ##
      # Validation rules used when creating or updating an access rule.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence([
          :package,
          :controller,
          :create_access,
          :read_access,
          :update_access,
          :delete_access
        ])

        validates_type(
          TrueClass,
          [:create_access, :read_access, :update_access, :delete_access]
        )
      end
    end # AccessRule
  end # Model
end # Users
