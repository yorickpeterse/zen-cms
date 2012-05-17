module Dashboard
  module Model
    ##
    # Model for the table that contains the active widgets for a user.
    #
    # @since 2012-01-12
    #
    class Widget < Sequel::Model
      many_to_one :users, :class => 'Users::Model::User'

      ##
      # Returns an integer containing the order of the last widget. If no
      # widgets were found 0 is returned.
      #
      # @since  2012-01-15
      # @param  [Fixnum] user_id The ID of the user for which to retrieve the
      #  widget order.
      # @return [Fixnum]
      #
      def self.last_order(user_id)
        rows = select(:order) \
          .filter(:user_id => user_id) \
          .order(:order.desc) \
          .limit(1) \
          .all

        if rows.empty?
          return 0
        else
          return rows[0].order
        end
      end

      ##
      # Validates the model instance before saving it in the database.
      #
      # @since 2012-01-13
      #
      def validate
        validates_presence([:name, :order, :user_id])
        validates_integer(:user_id)
      end
    end # Widget
  end # Model
end # Dashboard
