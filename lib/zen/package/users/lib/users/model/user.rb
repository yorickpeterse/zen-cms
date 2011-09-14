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

          Ramaze::Current.action.node.session[:user] = user
          return user
        else
          return false
        end
      end

      ##
      # Generates a new BCrypt hash and saves it in the model. The hash is
      # *only* generated when the password isn't nil or empty.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] password The raw password
      #
      def password=(password)
        return if password.nil? or password.empty?

        password = BCrypt::Password.create(password, :cost => 10)

        super(password)
      end

      ##
      # Returns the current password
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [String]
      #
      def password
        val = super

        return BCrypt::Password.new(val) unless val.nil?
      end

      ##
      # Hook run before creating or updating an object.
      #
      # @author Yorick Peterse
      # @since  0.2.9
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
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence [:email, :name]
        validates_unique   :email
        validates_presence :password if new?
        validates_format   /^\S+@\S+\.\w{2,}/, :email
      end
    end # User
  end # Model
end # Users
