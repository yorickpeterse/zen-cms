require 'ramaze/gestalt'

module Zen
  ##
  # Module used for registering extensions, setting their details and the whole shebang.
  # Extensions follow the same directory structure as Rubygems and can actually be installed
  # using either Rubygems or by storing them in a custom directory. As long as you require
  # the correct file you're good to go.
  #
  # Extensions are added or "described" using a simple block and the add() method as following:
  #
  # bc. Zen::Extension.add do |ext|
  #   # ....
  # end
  #
  # When using this block you're required to set the following attributes:
  # 
  # * name: the name of the extension
  # * author: the name of the person who made the extension
  # * version: the current version, either a string or a numeric value
  # * about: a small description of the extension
  # * url: the URL to the extension's website
  # * identifier: unique identifier for the extension. The format is com.AUTHOR.EXTENSION
  # * directory: the root directory of the extension, set this using __DIR__('path')
  # 
  # Optionally you can also specify the attribute "menu" (more on that later).
  #
  # h2. Menu Items
  #
  # The extension system easily allows modules to add navigation/sub-navigation elements
  # to the backend menu. Each extension can have an attribute named "menu", this attribute
  # is an array of hashes. Each hash must have the following 2 keys (they're symbols):
  #
  # * title: the value used for both the title tag and the text of the anchor element
  # * url: the URI the navigation item will point to. Leading slash isn't required
  #
  # Optionally you can specify child elements using the "children" key. This key
  # will again contain an array of hashes just like regular navigation elements.
  # For example, one could do the following:
  #
  # @ext.menu = [{:title => "Dashboard", :url => "admin/dashboard"}]@
  #
  # Adding a number of child elements isn't very difficult either:
  #
  # bc. ext.menu = [{
  #   :title    => "Dashboard", :url => "admin/dashboard",
  #   :children => [{:title => "Child", :url => "admin/dashboard/child"}]
  # }]
  #
  # Once a certain number of navigation elements have been added you can generate the
  # HTML for a fully fledged navigation menu using the build_menu() method. This method
  # uses Gestalt to build the HTML and also takes care of permissions for each user/module.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  module Extension
    class << self
      attr_reader :extensions
      attr_accessor :classes
    end
    
    ##
    # Adds a new extension along with all it's details such as the name,
    # author, version and so on. Extensions can be added using a simple
    # block as following:
    #
    #  Zen::Extension.add do |ext|
    #    ext.name   = "Name"
    #    ext.author = "Author"
    #  end
    #
    # When adding a new extension the following setters are required:
    #
    # * name
    # * author
    # * version
    # * about
    # * url
    # * identifier
    # * directory
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Block] block Block containing information about the extension.
    #
    def self.add &block
      extension = Struct.new(:name, :author, :version, :about, :url, :identifier, :directory, :menu).new
      required  = [:name, :author, :version, :about, :url, :identifier, :directory]
      
      yield extension
      
      required.each do |m|
        if !extension.respond_to?(m) or extension.send(m).nil?
          raise "A loaded extension has no value set for the setter \"#{m}\""
        end
      end
      
      if !Ramaze.options.roots.include?(extension.directory)
        Ramaze.options.roots.push(extension.directory)
      end
      
      if @extensions.nil?
        @extensions = {}
      end
      
      @extensions[extension.identifier.to_s] = extension
    end
    
    ##
    # Shortcut method that can be used to retrieve an extension based on the
    # given extension identifier.
    #
    # @author Yorick Peterse
    # @param  [String] ident The extension's identifier
    # @return [Object]
    #
    def self.[] ident
      @extensions[ident]
    end
    
    ##
    # Builds a navigation menu for all installed extensions.
    # Extensions can have an infinite amount of sub-navigation
    # items. This method will generate an unordered list of items
    # of which each list item can contain N sub items.
    #
    # @author Yorick Peterse
    # @param  [String] css_class A string of CSS classes to apply to the
    # main UL element.
    # @since  0.1
    #
    def self.build_menu css_class = ''
      @g         = Ramaze::Gestalt.new
      menu_items = []
      
      @extensions.each do |ident, ext|
        if !ext.menu.nil?
          ext.menu.each do |m|
            menu_items.push(m)
          end
        end
      end
      
      # Sort the menu alphabetical
      menu_items = menu_items.sort_by do |item|
        item[:title]
      end
      
      @g.ul :class => css_class do
        if !menu_items.empty?
          menu_items.each do |m|
            self.nav_list(m)
          end
        end
      end
      
      return @g.to_s
    end
    
    private
    
    ##
    # Method that's used to generate the list items for each
    # navigation menu along with all sub elements.
    #
    # @author Yorick Peterse
    # @param  [Hash] menu Hash containing the navigation items (url, title, etc)
    # @since  0.1
    #
    def self.nav_list menu
      @g.li do
        if menu[:url][0] != '/'
          menu[:url] = '/' + menu[:url]
        end
        
        @g.a :href => menu[:url], :title => menu[:title] do
          menu[:title]
        end
        
        if menu.key?(:children)
          @g.ul do
            menu[:children].each do |c|
              self.nav_list(c)
            end
          end
        end
      end
    end
    
  end
end