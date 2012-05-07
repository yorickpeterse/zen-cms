module Categories
  #:nodoc:
  module Model
    ##
    # Model for managing and retrieving categories.
    #
    # ## Events
    #
    # All available events will receive an instance of
    # {Categories::Model::Category}. Do note that the event
    # ``after_delete_category`` will receive an instance of this model *after*
    # ``#destroy()`` has been invoked on the instance. This means that you can
    # not save any changes made to the object as the database no longer
    # exists.
    #
    # Say you want to notify a user whenever a category is removed you could do
    # the following:
    #
    #     # "mail" can be installed by running gem install mail.
    #     require 'mail'
    #
    #     Zen::Event.listen(:delete_category) do |category|
    #       user = Users::Model::User[:name => 'admin']
    #       Mail.deliver do
    #         from    'example@domain.com'
    #         to      user.email
    #         subject "Category \"#{category.name}\" has been removed"
    #           "has been removed from the database."
    #       end
    #     end
    #
    # @since 0.1
    # @event before\_new\_category
    # @event after\_new\_category
    # @event before\_edit\_category
    # @event after\_edit\_category
    # @event before\_delete\_category
    # @event after\_delete\_category
    #
    class Category < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing the column names that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [:parent_id, :name, :description, :slug, :category_group_id]

      many_to_one :category_group, :class => 'Categories::Model::CategoryGroup'
      many_to_one :parent        , :class => self

      plugin :sluggable, :source => :name, :frozen => false

      plugin :events,
        :before_create  => :before_new_category,
        :after_create   => :after_new_category,
        :before_update  => :before_edit_category,
        :after_update   => :after_edit_category,
        :before_destroy => :before_delete_category,
        :after_destroy  => :after_delete_category

      ##
      # Searches for a set of category groups using the specified search query.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:name, query))
      end

      ##
      # Validates the model.
      #
      # @since  0.1
      #
      def validate
        validates_presence([:name, :category_group_id])
        validates_max_length(255, [:name, :slug])
        validates_unique(:slug)
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
    end # Category
  end # Model
end # Categories
