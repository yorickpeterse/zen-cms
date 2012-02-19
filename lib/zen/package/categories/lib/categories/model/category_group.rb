module Categories
  #:nodoc:
  module Model
    ##
    # Model that represents a single category group.
    #
    # ## Events
    #
    # All available events receive an instance of
    # {Categories::Model::CategoryGroup}. However, the
    # ``after_delete_category_group`` event will receive an instance that has
    # already been removed from the database. This means that you can not make
    # changes to the object and call ``#save()``.
    #
    # Example of logging when a new category group is created:
    #
    #     Zen::Event.listen(:after_new_category_group) do |group|
    #       Ramaze::Log.info("New category: \"#{group.name}\"")
    #     end
    #
    # Maybe you want to automatically add a category group to a section:
    #
    #     Zen::Event.listen(:after_new_category_group) do |group|
    #       section = Sections::Model::Section[5]
    #
    #       begin
    #         section.add_category_group(group)
    #       rescue => e
    #         Ramaze::Log.error(e)
    #       end
    #     end
    #
    # @since 0.1
    # @event before_new_category_group
    # @event after_new_category_group
    # @event before_edit_category_group
    # @event after_edit_category_group
    # @event before_delete_category_group
    # @event after_delete_category_group
    #
    class CategoryGroup < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing the column names that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [:name, :description]

      one_to_many  :categories, :class => 'Categories::Model::Category'
      many_to_many :sections,   :class => 'Sections::Model::Section'

      plugin :association_dependencies, :categories => :delete

      plugin :events,
        :before_create  => :before_new_category_group,
        :after_create   => :after_new_category_group,
        :before_update  => :before_edit_category_group,
        :after_update   => :after_edit_category_group,
        :before_destroy => :before_delete_category_group,
        :after_destroy  => :after_delete_category_group

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
      # Validation rules for the model.
      #
      # @since  0.1
      #
      def validate
        validates_presence(:name)
        validates_max_length(255, :name)
      end

      ##
      # Hook that is run before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :description])

        super
      end
    end # CategoryGroup
  end # Model
end # Categories
