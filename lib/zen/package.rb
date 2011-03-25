require 'ramaze/gestalt'
require __DIR__('helper/acl')
require __DIR__('liquid/controller_behavior')
require __DIR__('error/package_error')

#:nodoc:
module Zen
  ##
  # Module used for registering extensions and themes, setting their details and the 
  # whole shebang. Packages follow the same directory structure as Rubygems and can 
  # actually be installed using either Rubygems or by storing them in a custom directory. 
  # As long as you require the correct file you're good to go.
  #
  # Packages are added or "described" using a simple block and the add() method as 
  # following:
  #
  #     Zen::Package.add do |ext|
  #       # ....
  #     end
  #
  # When using this block you're required to set the following attributes:
  #
  # * name: the name of the package
  # * author: the name of the person who made the package
  # * about: a small description of the package
  # * url: the URL to the package's website
  # * identifier: unique identifier for the package. The format is com.AUTHOR.NAME for
  # extensions and com.AUTHOR.themes.NAME for themes.
  # * directory: the root directory of the package, set this using __DIR__('path')
  # 
  # Optionally you can also specify the attribute "menu" (more on that later).
  #
  # ## Menu Items
  #
  # The package system easily allows modules to add navigation/sub-navigation elements
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
  #     ext.menu = [{:title => "Dashboard", :url => "admin/dashboard"}]
  #
  # Adding a number of child elements isn't very difficult either:
  #
  #     ext.menu = [{
  #       :title    => "Dashboard", :url => "admin/dashboard",
  #       :children => [{:title => "Child", :url => "admin/dashboard/child"}]
  #     }]
  #
  # Once a certain number of navigation elements have been added you can generate the
  # HTML for a fully fledged navigation menu using the build_menu() method. This method
  # uses Gestalt to build the HTML and also takes care of permissions for each user/module.
  #
  # ## Migrations
  #
  # If your package uses it's own database tables it's best to use migrations as these make
  # it very easy to install/uninstall the extension. Migrations should be put in the root
  # directory of your extension. For example, if your extension is in "foobar" the migrations
  # should be located in "foobar/migrations", the lib directory in "foobar/lib", etc.
  #
  # Migrations can be executed using the Thor task "package:migrate" or "db:migrate",
  # the latter will install all packages while the first one will only install the 
  # specified packages. For more information on these tasks execute the following command:
  #
  #     $ thor -T
  #
  # ## Identifiers
  #
  # Package identifiers should always have the following format:
  #
  #     com.VENDOR.NAME
  #
  # For example:
  #
  #     com.zen.sections
  #
  # @author Yorick Peterse
  # @since  0.1
  # @attr_reader [Array] packages Array containing the instances of all packages.
  #
  module Package
    class << self
      attr_reader :packages
    end
    
    ##
    # Adds a new package along with all it's details such as the name,
    # author, version and so on. Extensions can be added using a simple
    # block as following:
    #
    #     Zen::Package.add do |ext|
    #       ext.name   = "Name"
    #       ext.author = "Author"
    #     end
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
    # You can also set "migration_dir" to a directory with all migrations. By default
    # Zen will assume that it's 2 levels above your root directory.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @yield  [package] Object containing all setters and getters for each package.
    #
    def self.add
      package = Zen::StrictStruct.new(
        :name, :author, :about, :url, :identifier, :directory, :menu, :migration_dir
      ).new

      required = [:name, :author, :about, :identifier, :directory]
      
      yield package
      
      package.validate(required) do |k|
        raise(Zen::PackageError, "The following package key is missing: #{k}")
      end

      # Update the root but prevent duplicates
      if !Ramaze.options.roots.include?(package.directory)
        Ramaze.options.roots.push(package.directory)
      end

      # Update the language directory
      if !Zen::Language.options.paths.include?(package.directory)
        Zen::Language.options.paths.push(package.directory)
      end

      # Validate the directories
      [:directory, :migration_dir].each do |k|
        if package.respond_to?(k) and !package.send(k).nil?
          if !File.exist?(package.send(k))
            raise(PackageError, "The directory #{package.send(k)} does not exist.")
          end
        end
      end
      
      @packages                          = {} if @packages.nil?
      @packages[package.identifier.to_s] = package 
    end
    
    ##
    # Shortcut method that can be used to retrieve an extension or theme based on the
    # given extension identifier.
    #
    # @author Yorick Peterse
    # @param  [String] ident The package's identifier
    # @return [Object]
    #
    def self.[](ident)
      @packages[ident.to_s]
    end
    
    ##
    # Builds a navigation menu for all installed extensions.
    # Extensions can have an infinite amount of sub-navigation
    # items. This method will generate an unordered list of items
    # of which each list item can contain N sub items.
    #
    # @author Yorick Peterse
    # @param  [String]  css_class A string of CSS classes to apply to the main UL element.
    # @param  [Hash]    permissions Hash containing the permissions as returned by
    # Ramaze::Helper::ACL#extension_permissions
    # @param  [Boolean] all When set to true all elements will be displayed opposed to 
    # only those the user is allowed to see.
    # @since  0.1
    #
    def self.build_menu(css_class = '', permissions = {}, all = false)
      @g          = Ramaze::Gestalt.new
      menu_items  = []
      identifiers = []

      # Build a list of all allowed extensions
      permissions.each do |ident, rules|
        if rules.include?(:read)
          identifiers.push(ident)
        end
      end
      
      @packages.each do |ident, ext|
        # Got a menu for us?
        if !ext.menu.nil?
          if identifiers.include?(ext.identifier) or all == true
            ext.menu.each do |m|
              menu_items.push(m)
            end
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
