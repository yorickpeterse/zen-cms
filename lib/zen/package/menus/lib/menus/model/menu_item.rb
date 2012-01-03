module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing individual menu items in a group.
    #
    # @since  0.2a
    #
    class MenuItem < Sequel::Model
      include Zen::Model::Helper

      plugin :tree, :order => :sort_order

      many_to_one :menu  , :class => 'Menus::Model::Menu'
      many_to_one :parent, :class => self

      ##
      # Searches for a set of menu items.
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
      # Specifies all validation rules that will be used when creating or
      # updating a menu item.
      #
      # @since  0.2a
      #
      def validate
        validates_presence([:name, :url])
        validates_max_length(255, [:name, :url, :html_class, :html_id])
        validates_integer([:sort_order, :parent_id])
        validates_format(/^[a-zA-Z\-_0-9\s]*$/, :html_class)
        validates_format(/^[a-zA-Z\-_0-9]*$/  , :html_id)
      end

      ##
      # Sets the ID of the parent navigation item but *only* if it's not empty
      # and not the same as the current ID.
      #
      # @since  0.3
      # @param  [Fixnum] parent_id The ID of the parent navigation item.
      #
      def parent_id=(parent_id)
        return if parent_id == id
        return super(parent_id)
      end

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :url, :html_class, :html_id])

        super
      end
    end # MenuItem
  end # Model
end # Menus
