#:nodoc:
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

      # Define our relations
      one_to_many :menu_items, :class => "Menus::Model::MenuItem"

      ##
      # Specifies all validates rules used when creating or updating a menu.
      # A slug will be generated when a menu is first created but after that
      # they are required to ensure that they don't collide with existing slugs.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def validate
        validates_presence :name
        validates_presence :slug unless new?
        validates_unique   :slug

        # Prevent people from entering random crap for class and ID names
        validates_format(/^[a-zA-Z\-_0-9]*/, [:html_class, :html_id])
      end
    end # Menu
  end # Model
end # Menus
