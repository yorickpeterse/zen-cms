module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing groups of menu items.
    #
    # @since  0.2a
    #
    class Menu < Sequel::Model
      include Zen::Model::Helper

      plugin :sluggable, :source => :name, :freeze => false

      one_to_many :menu_items, :class => 'Menus::Model::MenuItem'

      ##
      # Searches for a set of menus.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(
          search_column(:name, query) |
          search_column(:html_class, query) |
          search_column(:html_id, query)
        )
      end

      ##
      # Specifies all validates rules used when creating or updating a menu.
      #
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
