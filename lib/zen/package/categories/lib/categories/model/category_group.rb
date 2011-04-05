#:nodoc:
module Categories
  #:nodoc:
  module Model
    ##
    # Model that represents a single category group. Each category group
    # has the following relations to other models:
    #
    # * categories (one to many)
    # * sections (many to many)
    #
    # When saving or creating a category group the "name" field is required
    # and should be no longer than 255 characters.
    #
    class CategoryGroup < Sequel::Model
      one_to_many  :categories, :class => "Categories::Model::Category"
      many_to_many :sections  , :class => "Sections::Model::Section"
      
      ##
      # Validation rules for our model.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence        :name
        validates_max_length 255, :name
      end
    end
  end
end
