#:nodoc:
module Users
  #:nodoc:
  module Model
    ##
    # Model that represents a single user.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class User < Sequel::Model
      class << self
        include ::Innate::Trinity
      end

      plugin :timestamps, :create => :created_at, :update => :updated_at

      many_to_many(
        :user_groups,
        :class => "Users::Model::UserGroup",
        :eager => [:access_rules]
      )

      one_to_many(:access_rules, :class => "Users::Model::AccessRule")

      ##
      # Try to authenticate the user based on the specified credentials. If the
      # user credentials were incorrect false will be returned, true
      # otherwise.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Hash] creds The specified credentials
      # @return [Users::Model::User|FalseClass]
      #
      def self.authenticate(creds)
        email    = creds['email']
        password = creds['password']

        return false if email.nil? or password.nil?

        user = self[:email => email]

        if !user.nil? and user.password == password and user.status == 'open'
          # Overwrite all the global settings with the user specific ones
          [:language, :frontend_language, :date_format].each do |setting|
            value = Zen::Plugin.plugin(:settings, :get, setting).value

            if user.respond_to?(setting)
              got = user.send(setting)

              if got.nil? or got.empty?
                user.send("#{setting}=", value)
              end
            end
          end

          action.node.session[:user] = user
          return user
        else
          return false
        end
      end

      ##
      # Generates a new hash based on the specified password. Each
      # password is generated with a cost of 15, this makes the login
      # process slower but also more secure.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] raw_password The raw password
      #
      def password= raw_password
        pwd = BCrypt::Password.create(raw_password, :cost => 10)
        super(pwd)
      end

      ##
      # Returns the current password
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [String]
      #
      def password
        BCrypt::Password.new(super)
      end

      ##
      # Specifies all validation rules
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence [:email, :name]
        validates_presence :status   unless new?
        validates_presence :password if new?

        validates_format(/^\S+@\S+\.\w{2,}/, :email)
      end
    end # User
  end # Model
end # Users
