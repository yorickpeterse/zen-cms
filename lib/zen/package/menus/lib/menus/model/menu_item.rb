module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing individual menu items in a group.
    #
    # @author Yorick Peterse
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
      # @author Yorick Peterse
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
      # @author Yorick Peterse
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
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [Fixnum] parent_id The ID of the parent navigation item.
      #
      def parent_id=(parent_id)
        if !(parent_id.respond_to?(:empty?) and !parent_id.empty?) \
        and parent_id != self.id
          super(parent_id)
        end
      end
    end # MenuItem
  end # Model
end # Menus
