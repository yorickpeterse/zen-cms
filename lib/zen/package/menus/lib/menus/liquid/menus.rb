require 'ramaze/gestalt'

module Menus
  module Liquid
    ##
    # The menus tag can be used to display all menu items for a given menu slug or ID.
    # Basic usage of this tag is as following:
    #
    #     {% menus slug="main" %}
    #
    # Given we had a menu of which the slug is "main" the output would look like the this:
    #
    #     <ul>
    #         <li>
    #             <a href="http://zen-cms.com/" title="Zen CMS">Zen CMS</a>
    #         </li>
    #     </ul>
    #
    # This tag takes the following arguments: 
    #
    # * slug: the slug of the menu for which to retrieve all items.
    # * id: the ID of the menu for which to retrieve all items.
    # * order: string (either "asc" or "desc") that will be used to order the menu items.
    #
    # If both the slug and ID are specified the ID will be used instead of the slug.
    #
    # @example
    #  {% menus slug="main" order="asc" %}
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class Menus < ::Liquid::Tag
      include ::Zen::Liquid::General

      ##
      # Initializes the tag class and converts the arguments string into a key/value
      # hash.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [String] tag_name The name of the tag ("menus").
      # @param  [String] arguments All arguments passed as key="value" combinations.
      # @param  [String] tokens All tokens passed to the tag.
      # 
      def initialize(tag_name = 'menus', arguments = '', tokens = '')
        super

        @arguments = {
          'order' => 'desc'
        }.merge(parse_key_values(arguments))

        @args_parsed = false
      end

      ##
      # Retrieves the specified menu, generates the HTML and renders the Liquid template.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Liquid::Context] context The current Liquid instance.
      # @return [String] The HTML for the specified navigation menu. 
      #
      def render(context)
        if @args_parsed == false
          @arguments = merge_context(@arguments, context) 
        end

        @args_parsed = true
        menu_items   = []
        
        if @arguments.key?('id')
          menu = ::Menus::Models::Menu[@arguments['slug'].to_i]

        elsif @arguments.key?('slug')
          menu = ::Menus::Models::Menu[:slug => @arguments['slug']]

        else
          raise(
            ArgumentError, 
            "You need to specify either the ID or the slug in order to retrieve a menu."
          )
        end

        return if menu.nil?

        menu_items = ::Menus::Models::MenuItem.filter(:menu_id => menu.id)
          .order(:order.send(@arguments['order']))
        
        # Build the navigation menu
        @g                 = ::Ramaze::Gestalt.new
        attributes         = {}
        attributes[:class] = menu.css_class if !menu.css_class.nil?
        attributes[:id]    = menu.css_id if !menu.css_id.nil?

        # Organize all menu items in a parent/child hierachy
        items_ordered = {}

        @g.ul(attributes) do
          menu_items.each do |item| 
            if item.parent_id.nil?
              self.menu_item(item)
            end
          end
        end

        return @g.to_s
      end

      ##
      # Helper method used for generating a <li> and <a> tag for the current navigation 
      # item. If the item has any sub items those will be generated as well.
      #
      # @author Yorick Peterse
      # @since  0.2a
      # @param  [Object] item The current navigation item
      #
      def menu_item(item)
        attributes         = {}
        attributes[:class] = item.css_class if !item.css_class.nil?
        attributes[:id]    = item.css_id if !item.css_id.nil?
        children           = item.children

        @g.li(attributes) do
          if !item.url.nil? and !item.url.empty?
            @g.a(:href => item.url, :title => item.name) { item.name }
          else
            @g.span { item.name }
          end
          
          if !children.empty?
            @g.ul(:class => :children) do
              item.children.each do |i| 
                self.menu_item(i)
              end
            end
          end
        end # end of @g.li(attributes) do
      end

    end
  end
end
