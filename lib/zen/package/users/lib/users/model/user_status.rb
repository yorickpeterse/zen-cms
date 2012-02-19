module Users
  module Model
    ##
    # Model used for user statuses such as "Open" and "Unconfirmed".
    #
    # @since 03-11-2011
    #
    class UserStatus < Sequel::Model
      one_to_many :users, :class => 'Users::Model::User'

      plugin :association_dependencies, :users => :delete

      ##
      # Returns a hash where the keys are the IDs of the various statuses and
      # the values the translations.
      #
      # @since  03-11-2011
      # @return [Hash]
      #
      def self.dropdown
        hash = {}

        select(:id, :name).each do |row|
          hash[row.id] = lang("users.special.status_hash.#{row.name}")
        end

        return hash
      end
    end # UserStatus
  end # Model
end # Users
