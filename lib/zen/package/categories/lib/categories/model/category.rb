module Categories
  #:nodoc:
  module Model
    ##
    # Model for managing and retrieving categories.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Category < Sequel::Model
      many_to_one :category_group, :class => 'Categories::Model::CategoryGroup'
      many_to_one :parent        , :class => self

      plugin :sluggable, :source => :name, :frozen => false

      ##
      # Validates the model.
      #
      # @author Yorick Peterse
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
