#:nodoc:
module Users
  #:nodoc:
  module Model
    ##
    # Model that represents the very important user. This model
    # can be used for both CRUD actions as well as authenticating a user.
    # Passwords are encrypted using Bcrypt using the Ruby Bcrypt gem.
    #
    # This model has the following relations:
    #
    # * user groups (many to many), eager loads all access rules
    # * access rules (one to many)
    #
    # The following plugins are used by this model:
    #
    # * timestamps
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class User < Sequel::Model
      class << self
        include ::Innate::Trinity
      end

      plugin :timestamps, :create => :created_at, :update => :updated_at
      
      many_to_many :user_groups, :class => "Users::Model::UserGroup", :eager => [:access_rules]
      one_to_many :access_rules, :class => "Users::Model::AccessRule"
      
      ##
      # Try to authenticate the user based on the specified credentials.
      # If the user credentials were incorrect false will be returned,
      # true otherwise.
      #
      # Note that this method will NOT perform any sanitizing, that should be handled
      # by the controller instead.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Hash] creds The specified credentials
      # @return [Object/Boolean] new instance of the given user.
      #
      def self.authenticate creds
        email    = creds['email']
        password = creds['password']

        if email.nil? or password.nil?
          return false
        end

        user = self[:email => email]

        if !user.nil? and user.password == password and user.status == 'open'
          # Overwrite all the global settings with the user specific ones
          ::Zen::Settings.each do |k, v|
            if user.respond_to?(k)
              got = user.send(k)
              
              if got.nil? or got.empty?
                user.send("#{k}=", v)
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
      # @return [Void]
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
      # @todo   Email validation using regular expressions is bad, a DNS call would be
      # much better.
      #
      def validate
        validates_presence [:email, :name]
        validates_presence :status unless new?
        validates_format(/[a-zA-Z0-9\.\_\%\+\-]+@[a-zA-Z0-9\.\-]+\.[a-zA-Z]{2,4}/, :email)
      end
    end
  end
end
