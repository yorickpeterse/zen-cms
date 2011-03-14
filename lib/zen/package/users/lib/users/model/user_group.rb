#:nodoc:
module Users
  #:nodoc:
  module Models
    ##
    # Model that represents a single user group. This model has the following
    # relations:
    #
    # * users (many to many)
    # * access rules (one to many)
    #
    # This model uses the following plugins:
    #
    # * sluggable
    # 
    # @author Yorick Peterse
    # @since  0.1
    #
    class UserGroup < Sequel::Model
      many_to_many(:users      , :class => "Users::Models::User")
      one_to_many(:access_rules, :class => "Users::Models::AccessRule")
      
      plugin :sluggable , :source => :name, :freeze => false
      
      ##
      # Validation rules for each user group used when
      # creating or updating a group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence [:name, :super_group]
        validates_presence :slug unless new?
        validates_unique   :slug

        validates_type TrueClass, :super_group
      end
    end
  end
end
