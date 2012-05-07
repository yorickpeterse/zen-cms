module Users
  module Model
    ##
    # Model that represents a single user.
    #
    # @example Sending an Email for a new user
    #  Zen::Event.listen(:after_new_user) do |user|
    #    Mail.deliver do
    #      from    'user@domain.tld'
    #      to      user.email
    #      subject 'Your new account'
    #      body    "Dear #{user.name}, your account has been created."
    #    end
    #  end
    #
    # @since 0.1
    # @event before\_new\_user
    # @event after\_new\_user
    # @event before\_edit\_user
    # @event after\_edit\_user
    # @event before\_delete\_user
    # @event after\_delete\_user
    #
    class User < Sequel::Model
      ##
      # Regex to do some basic Email validation. Emails such as foo@bar,
      # "foo@bar.com" and "foo@bar.a.b" are all valid but "foo bar@bar.com"
      # isn't.
      #
      EMAIL_REGEX = '^[^@]\S+@\S+(\.[a-z]+)*[^.]$'

      ##
      # Array containing the columns that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [
        :email,
        :name,
        :website,
        :password,
        :confirm_password,
        :user_status_id,
        :language,
        :frontend_language,
        :date_format,
        :user_group_pks
      ]

      include Zen::Model::Helper

      many_to_many :user_groups, :class => 'Users::Model::UserGroup',
        :eager => [:permissions]

      many_to_one :user_status, :class => 'Users::Model::UserStatus'
      one_to_many :permissions, :class => 'Users::Model::Permission'
      one_to_many :widgets,     :class => 'Dashboard::Model::Widget'

      plugin :timestamps, :create => :created_at, :update => :updated_at
      plugin :association_dependencies, :permissions => :delete

      plugin :events,
        :before_create  => :before_new_user,
        :after_create   => :after_new_user,
        :before_update  => :before_edit_user,
        :after_update   => :after_edit_user,
        :before_destroy => :before_delete_user,
        :after_destroy  => :after_delete_user

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

        if !user.nil? and user.password == password \
        and user.user_status.allow_login == true
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

        password = BCrypt::Password.create(
          Zen::Security.sanitize(password),
          :cost => 10
        )

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
        # Password is sanitized in password=.
        sanitize_fields([
          :email, :name, :website, :language, :frontend_language, :date_format
        ])

        if self.user_status_id.nil?
          self.user_status_id = Users::Model::UserStatus[:name => 'closed'].id
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
        validates_format(Regexp.new(EMAIL_REGEX), :email)
        validates_presence(:password) if new?
        validates_max_length(255, [:email, :name, :website])
      end

      ##
      # Gets the name of the user's status and returns it in the current
      # language.
      #
      # @since  03-11-2011
      # @return [String]
      #
      def user_status_name
        return lang("users.special.status_hash.#{user_status.name}")
      end

      ##
      # Activates the user.
      #
      # @since 03-11-2011
      #
      def activate!
        update(
          :user_status_id => Users::Model::UserStatus[:name => 'active'].id
        )
      end

      ##
      # Closes the user account.
      #
      # @since 03-11-2011
      #
      def close!
        update(
          :user_status_id => Users::Model::UserStatus[:name => 'closed'].id
        )
      end
    end # User
  end # Model
end # Users
