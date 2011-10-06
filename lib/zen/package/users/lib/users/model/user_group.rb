#:nodoc:
module Users
  #:nodoc:
  module Model
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
      many_to_many :users      , :class => 'Users::Model::User'
      one_to_many  :permissions, :class => 'Users::Model::Permission'

      plugin :sluggable, :source => :name, :freeze => false
      plugin :association_dependencies, :permissions => :delete,
        :users => :nullify

      ##
      # Validation rules for each user group used when
      # creating or updating a group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence([:name, :super_group])
        validates_unique(:slug)

        validates_type(TrueClass, :super_group)
      end
    end # UserGroup
  end # Model
end # Users
