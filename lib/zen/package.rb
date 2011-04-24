require 'ramaze/gestalt'
require __DIR__('error/package_error')
require __DIR__('package/base')

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
  # * name: the name of the package in lowercased letters and/or numbers.
  # * author: the name of the person who made the package.
  # * about: a small description of the package.
  # * url: the URL to the package's website.
  # * directory: the root directory of the package, set this using __DIR__('path').
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
  #     $ rake -T
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  module Package
    ##
    # Hash containing all the registered packages. The keys of this hash are the names
    # of all packages and the values the instances of Zen::Package::Base.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Registered = {}

    ##
    # Array containing all controllers of all packages.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Controllers = []

    ##
    # Adds a new package along with all it's details such as the name, author, version 
    # and so on. Extensions can be added using a simple block as following:
    #
    #     Zen::Package.add do |ext|
    #       ext.name   = "name"
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
      package = Zen::Package::Base.new
      
      yield package

      # Validate the package
      package.validate
      package.name = package.name.to_sym

      # Update the root but prevent duplicates
      if !Ramaze.options.roots.include?(package.directory)
        Ramaze.options.roots.push(package.directory)
      end

      # Update the language directory
      if !Zen::Language.options.paths.include?(package.directory)
        Zen::Language.options.paths.push(package.directory)
      end

      package.controllers.each do |name, controller|
        controller = controller.to_s

        if !Controllers.include?(controller)
          Controllers.push(controller)
        end
      end
      
      Registered[package.name.to_sym] = package 
    end

    ##
    # Retrieves the package for the given name.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def self.[](name)
      name = name.to_sym

      if Registered.empty?
        raise(PackageError, "No packages have been added yet.")
      end

      if !Registered.key?(name)
        raise(PackageError, "The package \"#{name}\" doesn't exist.")
      end

      return Registered[name]
    end

    ##
    # Builds a navigation menu for all installed extensions.
    # Extensions can have an infinite amount of sub-navigation
    # items. This method will generate an unordered list of items
    # of which each list item can contain N sub items.
    #
    # @author Yorick Peterse
    # @param  [String] css_class A string of CSS classes to apply to the main UL element.
    # @param  [Hash] permissions Hash containing the permissions as returned by
    # Ramaze::Helper::ACL.extension_permissions
    # @since  0.1
    #
    def self.build_menu(css_class = '', permissions = {})
      @g           = Ramaze::Gestalt.new
      @permissions = permissions
      menu_items   = []
      
      Registered.each do |name, pkg|
        # Got a menu for us?
        if !pkg.menu.nil?
          pkg.menu.each do |m|
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
    def self.nav_list(menu)
      if menu[:url][0] != '/'
        menu[:url] = '/' + menu[:url]
      end

      # Get the controller for the current item
      controller  = Ramaze::AppMap.at('/').url_map.at(menu[:url]).to_s
      read_access = @permissions[controller].include?(:read)

      # Ignore the menu item alltogether
      if !read_access and !menu.key?(:children)
        return
      end

      @g.li do
        # Easy way of disabling an item and not fucking up the menu
        if !read_access
          menu[:url] = '#'
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
