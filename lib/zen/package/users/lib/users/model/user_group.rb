module Users
  #:nodoc:
  module Model
    ##
    # Model that represents a single user group.
    #
    # @since 0.1
    # @event before_new_user_group
    # @event after_new_user_user
    # @event before_edit_user_group
    # @event after_edit_user_group
    # @event before_delete_user_group
    # @event after_delete_user_group
    #
    class UserGroup < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing the columns that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [:name, :slug, :description, :super_group]

      many_to_many :users      , :class => 'Users::Model::User'
      one_to_many  :permissions, :class => 'Users::Model::Permission'

      plugin :sluggable, :source => :name, :freeze => false

      plugin :association_dependencies,
        :permissions => :delete,
        :users       => :nullify

      plugin :events,
        :before_create  => :before_new_user_group,
        :after_create   => :after_new_user_group,
        :before_update  => :before_edit_user_group,
        :after_update   => :after_edit_user_group,
        :before_destroy => :before_delete_user_group,
        :after_destroy  => :after_delete_user_group

      ##
      # Searches for a set of users that match the given query.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:name, query))
      end

      ##
      # Validation rules for each user group used when
      # creating or updating a group.
      #
      # @since  0.1
      #
      def validate
        validates_presence([:name, :super_group])
        validates_max_length(255, :name)
        validates_unique(:slug)

        validates_type(TrueClass, :super_group)
      end

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :slug, :description])

        super
      end
    end # UserGroup
  end # Model
end # Users
