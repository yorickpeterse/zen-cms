module Categories
  #:nodoc:
  module Model
    ##
    # Model for managing and retrieving categories.
    #
    # @since  0.1
    #
    class Category < Sequel::Model
      include Zen::Model::Helper

      many_to_one :category_group, :class => 'Categories::Model::CategoryGroup'
      many_to_one :parent        , :class => self

      plugin :sluggable, :source => :name, :frozen => false

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
    end # Category
  end # Model
end # Categories
