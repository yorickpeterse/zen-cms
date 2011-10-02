require 'ramaze/gestalt'

module Menus
  #:nodoc:
  class Plugin
    ##
    # Plugin for displaying navigation menus. This plugin will take care of
    # recursively displaying all sub items and various other tasks, you merely
    # have to set a few options and then you can sit back and enjoy.
    #
    # The basic usage of this plugin is as following:
    #
    #     plugin(:menus, :menu => 'userguide')
    #
    # This would retrieve all menu items for the menu "userguide". Just like
    # other plugins you can specify a slug (as a string) or an ID (as an
    # instance of Fixnum).
    #
    # By default sub items are not displayed, in order to do so you have to set
    # the ``:sub`` option to true:
    #
    #     plugin(:menus, :menu => 'userguide', :sub => true)
    #
    # For more information about all the available options see {#initialize}.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Menus
      include ::Zen::Plugin::Helper

      ##
      # Creates a new instance of the plugin and saves the configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param [Hash] options Hash with configuration options.
      # @option options [Fixnum] :limit The maximum amount of root items
      #  to retrieve.
      # @option options [Fixnum] :offset The row offset for all root
      #  elements.
      # @option options [Fixnum|String] :menu The ID or slug of the menu
      #  for which to retrieve all menu items.
      # @option options [Boolean] :sub When set to false sub items will be
      #  ignored. This option is set to true by default.
      #
      def initialize(options = {})
        @options = {
          :limit  => 20,
          :offset => 0,
          :menu   => nil,
          :sub    => false,
          :order  => :asc
        }.merge(options)

        validate_type(@options[:limit] , :limit , [Fixnum])
        validate_type(@options[:offset], :offset, [Fixnum])
        validate_type(@options[:menu]  , :menu  , [String, Fixnum])
        validate_type(@options[:order] , :order , [String, Symbol])
      end

      ##
      # Renders the navigation menu based on the given configuration options.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [String] The HTML for the navigation menu.
      #
      def call
        # Retrieve the menu
        if @options[:menu].is_a?(String)
          menu = ::Menus::Model::Menu[:slug => @options[:menu]]
        else
          menu = ::Menus::Model::Menu[@options[:menu]]
        end

        return if !menu

        # Get all menu items
        menu_items = ::Menus::Model::MenuItem \
          .filter(:menu_id => menu.id, :parent_id => nil) \
          .limit(@options[:limit], @options[:offset]) \
          .order(:sort_order.send(@options[:order])) \
          .all

        @g         = Ramaze::Gestalt.new
        attributes = {}
        items_tree = {}

        # Set the attributes for the main <ul> elements
        if !menu.html_class.nil?
          attributes[:class] = menu.html_class if !menu.html_class.empty?
        end

        if !menu.html_id.nil?
          attributes[:id] = menu.html_id if !menu.html_id.empty?
        end

        # Time to build the HTML
        @g.ul(attributes) do
          menu_items.each do |item|
            if item.parent_id.nil?
              generate_item(item)
            end
          end
        end

        return @g.to_s
      end

      private

      ##
      # Generates the HTML for a single <li> element and all sub elements.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Object] item An instance of the MenuItem model as returned by
      #  Sequel.
      #
      def generate_item(item)
        attributes = {}

        if !item.html_class.nil?
          attributes[:class] = item.html_class if !item.html_class.empty?
        end

        if !item.html_id.nil?
          attributes[:id] = item.html_id if !item.html_id.empty?
        end

        # Render the <li> tag
        @g.li(attributes) do
          @g.a(:href => item.url, :title => item.name) { item.name }

          # Generate all the sub elements
          if @options[:sub] === true
            children = item.children

            if !children.empty?
              @g.ul(:class => :children) do
                children.each do |child|
                  generate_item(child)
                end
              end
            end # if !children.empty?
          end
        end
      end
    end # Menus
  end # Plugin
end # Menus
