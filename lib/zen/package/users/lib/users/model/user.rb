#:nodoc:
module Users
  #:nodoc:
  module Model
    ##
    # Model that represents a single user.
    #
    # @since  0.1
    #
    class User < Sequel::Model
      include Zen::Model::Helper

      many_to_many :user_groups, :class => 'Users::Model::UserGroup',
        :eager => [:permissions]

      one_to_many :permissions, :class => 'Users::Model::Permission'

      plugin :timestamps, :create => :created_at, :update => :updated_at
      plugin :association_dependencies, :permissions => :delete

      ##
      # Searches for a set of users that match the given query.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(
          search_column(:name, query) | search_column(:email, query)
        )
      end

      ##
      # Try to authenticate the user based on the specified credentials..
      #
      # @since  0.1
      # @param  [Hash] creds The specified credentials
      # @return [Users::Model::User|FalseClass]
      #
      def self.authenticate(creds)
        email    = creds['email']
        password = creds['password']

        if email.nil? or password.nil?
          return false
        end

        user = self[:email => email]

        if !user.nil? and user.password == password and user.status == 'open'
          # Overwrite all the global settings with the user specific ones
          [:language, :frontend_language, :date_format].each do |setting|
            value = get_setting(setting).value

            if user.respond_to?(setting)
              got = user.send(setting)

              if got.nil? or got.empty?
                user.send("#{setting}=", value)
              end
            end
          end

          return user
        else
          return false
        end
      end

      ##
      # Generates a new BCrypt hash and saves it in the model. The hash is
      # *only* generated when the password isn't nil or empty.
      #
      # @since  0.1
      # @param  [String] password The raw password
      #
      def password=(password)
        return if password.nil? or password.empty?

        password = BCrypt::Password.create(password, :cost => 10)

        super(password)
      end

      ##
      # Returns the current password.
      #
      # @since  0.1
      # @return [BCrypt::Password|NilClass]
      #
      def password
        val = super

        return BCrypt::Password.new(val) unless val.nil?
      end

      ##
      # Hook run before creating or updating an object.
      #
      # @since  0.3
      #
      def before_save
        if self.status.nil? or self.status.empty?
          self.status = 'open'
        end

        super
      end

      ##
      # Specifies all validation rules
      #
      # @since  0.1
      #
      def validate
        validates_presence([:email, :name])
        validates_unique(:email)
        validates_presence(:password) if new?
        validates_max_length(255, [:email, :name, :website])
        validates_format(/^\S+@\S+\.\w{2,}/, :email)
      end
    end # User
  end # Model
end # Users
