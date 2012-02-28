module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing individual menu items in a group.
    #
    # @example Automatically prefix URLs with http
    #  Zen::Event.listen(:new_menu_item) do |item|
    #    unless item.url =~ /^http/
    #      item.url = 'http://' + item.url
    #      item.save
    #    end
    #  end
    #
    # @since 0.2a
    # @event before_new_menu_item
    # @event after_new_menu_item
    # @event before_edit_menu_item
    # @event after_edit_menu_item
    # @event before_delete_menu_item
    # @event after_delete_menu_item
    #
    class MenuItem < Sequel::Model
      include Zen::Model::Helper

      ##
      # Array containing the columns that can be set by the user.
      #
      # @since 17-02-2012
      #
      COLUMNS = [
        :parent_id, :name, :url, :sort_order, :html_class, :html_id, :menu_id
      ]

      plugin :tree, :order => :sort_order

      plugin :events,
        :before_create  => :before_new_menu_item,
        :after_create   => :after_new_menu_item,
        :before_update  => :before_edit_menu_item,
        :after_update   => :after_edit_menu_item,
        :before_destroy => :before_delete_menu_item,
        :after_destroy  => :after_delete_menu_item

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
      # Specifies all validation rules that will be used when creating or
      # updating a menu item.
      #
      # @since  0.2a
      #
      def validate
        validates_presence([:name, :url, :menu_id])
        validates_max_length(255, [:name, :url, :html_class, :html_id])
        validates_integer([:sort_order, :parent_id])
        validates_format(/^[a-zA-Z\-_0-9\s]*$/, :html_class)
        validates_format(/^[a-zA-Z\-_0-9]*$/  , :html_id)
      end

      ##
      # Hook that is called before creating a new object.
      #
      # @since 28-02-2012
      #
      def before_create
        # Set the sort order based on the order of the last item.
        if self.sort_order.nil?
          last = Zen.database[MenuItem.table_name] \
            .select(:sort_order + 1 => :sort_order) \
            .filter(:menu_id => self.menu_id) \
            .order(:sort_order.desc) \
            .limit(1) \
            .first

          unless last.nil?
            self.sort_order = last[:sort_order]
          end
        end

        super
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
