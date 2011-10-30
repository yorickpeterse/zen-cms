module Categories
  #:nodoc:
  module Model
    ##
    # Model that represents a single category group.
    #
    # @since  0.1
    #
    class CategoryGroup < Sequel::Model
      include Zen::Model::Helper

      one_to_many  :categories, :class => 'Categories::Model::Category'
      many_to_many :sections  , :class => 'Sections::Model::Section'

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
    end # CategoryGroup
  end # Model
end # Categories
