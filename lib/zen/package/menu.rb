require 'ramaze/gestalt'
require __DIR__('../helper/acl')

module Zen
  class Package
    ##
    # Class that represents a single navigation item that optionally contains a
    # number of sub elements.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    class Menu
      include Ramaze::Trinity
      include Ramaze::Helper::ACL

      # A string containing the URL of the current element.
      attr_reader :url

      # All the child elements of the current navigation element.
      attr_reader :children

      ##
      # Creates a new instance of the class and optionally processes all sub
      # navigation items.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [String] title The title or language key of the navigation
      #  element.
      # @param  [String] url The URL of the navigation element.
      # @param  [Hash] options A hash containing various options for the
      #  element.
      # @option options :permission A symbol containing the name of the
      #  permission required to show the navigation item.
      # @yield  [self]
      #
      def initialize(title, url, options = {})
        @title, @url = title, url
        @children    = []
        @options     = options

        yield(self) if block_given?
      end

      ##
      # Adds a new child element to the navigation menu.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @see    Zen::Package::Menu#initialize()
      #
      def menu(title, url, options = {}, &block)
        @children << self.class.new(title, url, options, &block)
      end

      ##
      # Returns the title of the navigation item. If possible it will be
      # translated, otherwise the original value will be used.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @return [String]
      #
      def title
        begin
          return lang(@title)
        rescue
          return @title
        end
      end

      ##
      # Builds the HTML for the current navigation menu using Ramaze::Gestalt.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [Array] permissions An array of permissions for the current
      #  user.
      # @return [String|NilClass] The HTML of the navigation menu.
      #
      def html(permissions = [])
        # Skip the navigation menu and all it's child elements if the user isn't
        # allowed to view it.
        return if !user_authorized?(@options[:permission])

        g        = Ramaze::Gestalt.new
        children = []

        g.li do
          g.a(title, :href => url, :title => title)

          unless @children.empty?
            @children.each do |child|
              html = child.html(permissions)

              unless html.nil?
                children << html
              end
            end

            unless children.empty?
              g.ul do
                g.out << children
              end
            end
          end
        end

        return g.to_s
      end
    end # Menu
  end # Package
end # Zen
