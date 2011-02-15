module Categories
  module Models
    ##
    # Model that represents a single category. This model has
    # the following relations:
    #
    # * category groups (one to one)
    # * self (many to one)
    #
    # This model uses the following plugins:
    #
    # * sluggable (source: "name")
    #
    # When creating or saving a category the fields "name" and "slug" are required.
    # The latter is only needed when saving an existing category as a slug will be
    # generated whenever the field is empty. It's also important to remember
    # that slugs have to be unique. For more info see the validate() method.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Category < Sequel::Model
      one_to_one :category_groups
      many_to_one :parent, :class => self
      
      plugin :sluggable, :source => :name, :frozen => false
      
      ##
      # Validation rules for our model.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence    :name
        validates_max_length  255, [:name, :slug]
        validates_unique      :slug
      end
    end
  end
end
