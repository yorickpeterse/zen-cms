#:nodoc:
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

      private

      ##
      # Overrides the #to_slug() method of the sluggable plugin so that it works
      # with empty strings and nil values.
      #
      # @author Yorick Peterse
      # @since  28-09-2011
      # @param  [String|NilClass] value The value to convert to a slug.
      # @return [String]
      #
      def to_slug(value)
        if value.nil? or value.empty?
          value = name
        end

        return value.chomp.downcase.gsub(/[^a-z0-9]+/, '-')
      end
    end # Category
  end # Model
end # Categories
