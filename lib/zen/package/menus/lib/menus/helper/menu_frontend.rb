require 'ramaze/gestalt'

module Ramaze
  module Helper
    ##
    # Helper that allows you to render navigation menus in your templates.
    #
    # @since  0.3
    #
    module MenuFrontend
      ##
      # Renders a navigation menu's items based on the menu slug or ID.
      #
      # @example Render a menu by it's slug
      #  render_menu('main')
      #
      # @example Render a menu by it's ID
      #  render_menu(2)
      #
      # @example Render a menu without sub items
      #  render_menu('main', :sub => false)
      #
      # @since  0.3
      # @param  [String|Fixnum] menu The slug or ID of a menu to render.
      # @param  [Hash] options A hash containing various options to customize
      #  the return value.
      # @option options [Fixnum] :limit The amount of menu items to display. Set
      #  to 20 by default.
      # @option options [TrueClass|FalseClass] :sub Boolean that indicates if
      #  sub items should be rendered or not, set to true by default.
      # @option options [Symbol] :order The sort order method to call, can
      #  either be ``:asc`` or ``:desc``, set to ``:asc`` by default.
      # @return [String]
      #
      def render_menu(menu, options = {})
        options = {
          :limit => 20,
          :sub   => true,
          :order => :asc
        }.merge(options)

        menu  = Menus::Model::Menu.find_by_pk_or_slug(menu)
        items = Menus::Model::MenuItem \
          .filter(:parent_id => nil, :menu_id => menu.id) \
          .limit(options[:limit]) \
          .order(:sort_order.send(options[:order])) \
          .eager(:parent) \
          .all

        g     = Ramaze::Gestalt.new
        attrs = {}
        tree  = {}

        if !menu.html_class.nil? and !menu.html_class.empty?
          attrs[:class] = menu.html_class
        end

        if !menu.html_id.nil? and !menu.html_id.empty?
          attrs[:id] = menu.html_id
        end

        # Build the HTML
        g.ul(attrs) do
          items.each do |item|
            if item.parent_id.nil?
              render_menu_item(item, g, options)
            end
          end
        end

        return g.to_s
      end

      private

      ##
      # Generates the HTML for a single menu item.
      #
      # @since  0.3
      # @param  [Menus::Model::MenuItem] item The menu item to render.
      # @param  [Ramaze::Gestalt] g An instance of ``Ramaze::Gestalt`` to use
      #  for building the HTML.
      # @param  [Hash] options A hash of options, see the options hash for
      #  {Ramaze::Helper::MenuFrontend#render_menu} for more information.
      #
      def render_menu_item(item, g, options = {})
        attrs = {}

        if !item.html_class.nil? and !item.html_class.empty?
          attrs[:class] = item.html_class
        end

        if !item.html_id.nil? and !item.html_id.empty?
          attrs[:id] = item.html_id
        end

        g.li(attrs) do
          g.a(:href => item.url, :title => item.name) { item.name }

          # Render any sub menu items
          if options[:sub] == true
            children = item.children

            if !children.empty?
              g.ul(:class => :children) do
                children.each { |child| render_menu_item(child, g, options) }
              end
            end
          end
        end
      end
    end # MenuFrontend
  end # Helper
end # Ramaze
