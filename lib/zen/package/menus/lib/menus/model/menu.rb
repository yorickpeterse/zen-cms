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
      # Creates an array containing a hierarchy of menu items based on the
      # values of the "id" and "parent_id" columns. The advantage of this method
      # over the "tree" plugin that comes with Sequel is that it's capable of
      # building this structure using only a single query, the downside is that
      # it probably uses a bit more memory.
      #
      # The return value is an array of hashes. Each hash has the following
      # format:
      #
      #     {:node => #<Menus::Model::MenuItem>, :children => [...]}
      #
      # The :node key contains the menu item, the :children key contains an
      # array which in turn contains all the sub nodes (and so on).
      #
      # On average this method is about 2.5 times faster than using the tree
      # plugin's ``#children()`` method, see https://gist.github.com/1713481 for
      # a small benchmark.
      #
      # @example
      #  def loop_nodes(node)
      #    puts node[:node].id
      #
      #    node[:children].each do |child|
      #      loop_nodes(child)
      #    end
      #  end
      #
      #  loop_nodes(Menus::Model::Menu[1].menu_items_tree)
      #
      # @since  30-01-2012
      # @param  [Symbol] order The sort order to apply to menu items, set to
      #  :asc by default.
      # @param  [Fixnum|NilClass] limit The maximum amount of menu items to
      #  retrieve. Set to unlimited by default.
      # @return [Hash]
      #
      def menu_items_tree(order = :asc, limit = nil)
        nodes   = []
        indexes = {}
        rows    =  MenuItem.filter(:menu_id => id).limit(limit)

        # Create the basic structure for each node and index said node.
        rows.each do |item|
          node  = {:node => item, :children => []}
          nodes << node

          indexes[item.id] = nodes.rindex(node)
        end

        # Process the list of nodes in reverse order so that the child items can
        # be assigned properly.
        nodes.reverse.each do |node|
          # If there's a matching parent node the current node should be
          # assigned to that node and removed from the list. If there's no
          # parent item then the node is un-modified.
          if indexes[node[:node].parent_id]
            index = indexes[node[:node].parent_id]

            nodes[index][:children] << nodes.delete(node) if nodes[index]
          end
        end

        return sort_menu_items(nodes, order)
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

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :slug, :description, :html_class, :html_id])

        super
      end

      private

      ##
      # Sorts a set of sub nodes as returned by
      # {Menus::Model::Menu#menu_item_tree}.
      #
      # @since  01-02-2012
      # @param  [Array]  nodes An array of nodes to sort.
      # @param  [Symbol] order The sort order to apply.
      # @return [Array]
      #
      def sort_menu_items(nodes, order = :asc)
        return nodes if nodes.empty?

        nodes.sort! do |left, right|
          if order == :asc
            left[:node].sort_order <=> right[:node].sort_order
          else
            right[:node].sort_order <=> left[:node].sort_order
          end
        end

        nodes.each do |node|
          node[:children] = sort_menu_items(node[:children])
        end

        return nodes
      end
    end # Menu
  end # Model
end # Menus
