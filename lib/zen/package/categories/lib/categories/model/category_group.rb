#:nodoc:
module Categories
  #:nodoc:
  module Model
    ##
    # Model that represents a single category group.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CategoryGroup < Sequel::Model
      one_to_many  :categories, :class => "Categories::Model::Category"
      many_to_many :sections  , :class => "Sections::Model::Section"

      ##
      # Validation rules for the model.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence        :name
        validates_max_length 255, :name
      end
    end # CategoryGroup
  end # Model
end # Categories
