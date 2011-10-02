module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing groups of menu items.
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class Menu < Sequel::Model
      plugin :sluggable, :source => :name, :freeze => false

      one_to_many :menu_items, :class => 'Menus::Model::MenuItem'

      ##
      # Specifies all validates rules used when creating or updating a menu.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def validate
        validates_presence(:name)
        validates_unique(:slug)
        validates_max_length(255, [:name, :slug, :html_class, :html_id])
        validates_format(/^[a-zA-Z\-_0-9\s]*$/, :html_class)
        validates_format(/^[a-zA-Z\-_0-9]*$/  , :html_id)
      end
    end # Menu
  end # Model
end # Menus
