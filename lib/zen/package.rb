require 'ramaze/gestalt'
require __DIR__('package/menu')

module Zen
  ##
  # Zen::Package allows developers to register so called "packages". Packages
  # are collections of controllers, models, views and pretty much anything else
  # that goes in a typical Ramaze application. In fact, you can actually
  # distribute entire Ramaze applications as a package (though it would most
  # likely require some modifications).
  #
  # A package is registered by calling ``Zen::Package.add`` and passing a block
  # to it. This block will be yielded on a new instance of ``Zen::Package``:
  #
  #     Zen::Package.add do |p|
  #
  #     end
  #
  # When adding a package you must **always** set the following attributes:
  #
  # * name: the name of the package, should be a symbol
  # * title: the title of the package. This should be a language key such as
  #   "users.titles.index" as this allows users to view the package name in
  #   their chosen language.
  # * author: the name of the package's author.
  # * about: a description of the package, just like the title attribute this
  #   should be a language key, "users.description" is an example of such a key.
  # * root: the root directory of the package, this path should point to the
  #   directory containing your ``helper/`` and ``language/`` directories as
  #   well as any ``public/`` directories.
  #
  # Setting these (and other) attributes is very easy:
  #
  #     Zen::Package.add do |p|
  #       p.name   = :some_package
  #       p.title  = 'some_package.titles.index'
  #       p.author = 'John Doe'
  #       p.root   = __DIR__('some_package')
  #     end
  #
  # Besides the required attributes listed above you can also set the following
  # ones:
  #
  # * url: a URL that points to the website of the package.
  # * migrations: a directory containing all Sequel migrations.
  #
  # ## Package Structure
  #
  # Packages should have the same structure as generic Rubygems. In it's most
  # basic form this means you'll end up with a structure that looks like the
  # following:
  #
  #     root/
  #     |
  #     |__ lib/
  #        |__ package.rb
  #        |__ package/
  #           |__ controller/
  #           |__ helper/
  #
  # There's no requirement for the location of your migrations but it's
  # recommended to place it in the same directory as the ``lib/`` directory as
  # this is the convention followed by Zen itself.
  #
  # The advantage of this structure is that when a package is shipped via
  # Rubygems it can be loaded in exactly the same way as a normal gem. Say the
  # "some_package" example described earlier would be distributed via Rubygems,
  # all a developer would have to do to load the package is the following:
  #
  #     require 'some_package'
  #
  # It's not recommended to place packages or gems in the ``Zen`` namespace
  # unless they modify or add core features such as more validation methods for
  # ``Zen::Validation``.
  #
  # ## Menu Management
  #
  # Menus can be added by calling the method ``menu()`` on the object passed to
  # the block. This method takes a URL, a title/label and a hash of options.
  # Note that just like the ``name`` attribute the title/label should be a
  # language key.
  #
  #     Zen::Package.add do |p|
  #       p.menu('some_package.titles.index', '/admin/some-packages')
  #     end
  #
  # For more information see ``Zen::Package#menu()`` and ``Zen::Package::Menu``.
  #
  # ## Permissions
  #
  # When creating a package you can add a number of permissions. These
  # permissions can be assigned to a user or user group in the admin interface.
  # Permissions allow you to restrict access to certain actions to specific
  # users/user groups. A permission can be added by calling ``permission()`` on
  # the object passed to the block. Again the title of the permission should be
  # a langauge key so it can be displayed in a custom language:
  #
  #     Zen::Package.add do |p|
  #       p.permission(:show_some_package, 'packages.titles.index')
  #     end
  #
  # For more information on how to specify permission requirements in your
  # controllers see ``Ramaze::Helper::ACL``.
  #
  # ## Migrations
  #
  # Zen comes with two tasks that allow users and developers to update their
  # database, ``rake db:migrate`` and ``rake package:migrate``. For these tasks
  # to work there of course have to be migrations. When registering a package
  # you can set the ``migrations`` attribute. This attribute should contain a
  # path to a directory containing a group of timestamp based migrations such as
  # "1316770622_hello_world.rb".
  #
  # @since  0.1
  #
  class Package
    include Zen::Validation

    ##
    # Hash containing all the registered packages. The keys of this hash are the
    # names of all packages and the values the instances of Zen::Package::Base.
    #
    # @since  0.2.5
    #
    REGISTERED = {}

    # The name of the package.
    attr_reader :name

    # The author of the package.
    attr_accessor :author

    # The URL of the package.
    attr_accessor :url

    # The root directory of the package.
    attr_reader :root

    # The directory to all migrations.
    attr_accessor :migrations

    class << self
      ##
      # Adds a new package along with all it's details such as the name, author,
      # version and so on. Extensions can be added using a simple block as
      # following:
      #
      #     Zen::Package.add do |ext|
      #       ext.name   = "name"
      #       ext.author = "Author"
      #     end
      #
      # @since  0.1
      #
      def add
        package = self.new

        yield(package)
        package.validate

        REGISTERED[package.name] = package
      end

      ##
      # Retrieves the package for the given name.
      #
      # @example
      #  Zen::Package[:users]
      #
      # @since  0.1
      #
      def [](name)
        name = name.to_sym

        if REGISTERED.empty?
          raise(PackageError, "No packages have been added yet.")
        end

        if !REGISTERED.key?(name)
          raise(PackageError, "The package \"#{name}\" doesn't exist.")
        end

        return REGISTERED[name]
      end

      ##
      # Builds the entire navigation menu for all packages.
      #
      # @example
      #  Zen::Package.build_menu('left', [:edit_user, :show_user, :show_setting])
      #
      # @since  0.3
      # @param  [String] html_class An HTML class to apply to the <ul> element.
      # @param  [Array] permissions An array of permissions for the current
      #  user.
      # @return [String]
      #
      def build_menu(html_class = 'navigation', permissions = [])
        g = Ramaze::Gestalt.new

        g.ul(:class => html_class) do
          # Sort the hash
          keys = REGISTERED.keys.sort

          keys.each do |key|
            unless REGISTERED[key].menu.nil?
              g.out << REGISTERED[key].menu.html(permissions)
            end
          end
        end

        return g.to_s
      end
    end # class << self

    ##
    # Sets the name of the package. The name of a package should be a short and
    # unique name. A human readable version can be set using title=().
    #
    # @since  0.3
    # @param  [#to_sym] name The name of the package.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Sets the title of the package.
    #
    # @since  0.3
    # @param  [String] title The title or language key of the package.
    #
    def title=(title)
      @title = title
    end

    ##
    # Returns the title of the package. This method will try to translate it and
    # fall back to the original value in case the language key doesn't exist.
    #
    # @since  0.3
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
    # Sets the description of the package.
    #
    # @since  0.3
    # @param  [String] about The description of the package.
    #
    def about=(about)
      @about = about
    end

    ##
    # Tries to translate the description and returns it.
    #
    # @since  0.3
    # @return [String]
    #
    def about
      begin
        return lang(@about)
      rescue
        return @about
      end
    end

    ##
    # Sets the root directory of the package.
    #
    # @since  0.3
    # @param  [String] root The path to the root directory.
    #
    def root=(root)
      @root = root

      if !Ramaze.options.roots.include?(@root)
        Ramaze.options.roots << @root
      end

      if !Zen::Language.options.paths.include?(@root)
        Zen::Language.options.paths << File.join(@root, 'language')
      end

      if !Ramaze::HelpersHelper.options.paths.push.include?(@root)
        Ramaze::HelpersHelper.options.paths << @root
      end
    end

    ##
    # Sets all the navigation items for the package. Sub items can be specified
    # by calling this method and passing a block to it.
    #
    # @example
    #  Zen::Package.add do |p|
    #    p.menu('Hello,' ,'/admin/hello') do |sub|
    #      sub.menu('Sub menu', '/admin/hello/sub')
    #    end
    #  end
    #
    # @since  0.3
    # @see    Zen::Package::Menu#initialize()
    # @return [Zen::Package::Menu] The current navigation menu if no new one is
    #  specified.
    #
    def menu(title = nil, url = nil, options = {}, &block)
      if title.nil? and url.nil? and !block_given?
        return @menu
      end

      @menu = Zen::Package::Menu.new(title, url, options, &block)
    end

    ##
    # Adds a new permission along with it's title or language key.
    #
    # @example
    #  Zen::Package.add do |p|
    #    p.permission :show_user, 'users.titles.index'
    #    p.permission :edit_user, 'users.titles.edit'
    #  end
    #
    # @since  0.3
    # @param  [#to_sym] permission The name of the permission.
    # @param  [String] title The title or language key of the permission, shown
    #  in the admin interface.
    #
    def permission(permission, title)
      @permissions                  ||= {}
      @permissions[permission.to_sym] = title
    end

    ##
    # Returns the permissions for the current package. This method will
    # automatically try to translate the titles using the current language.
    #
    # @since  0.3
    # @return [Hash]
    #
    def permissions
      perms = {}

      @permissions.each do |perm, title|
        begin
          perms[perm] = lang(title)
        rescue
          perms[perm] = title
        end
      end

      return perms
    end

    ##
    # Validates all the attributes.
    #
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :title, :author, :about, :root])

      validates_filepath(:root)
      validates_filepath(:migrations) unless migrations.nil?

      # Check if the package hasn't been registered yet
      if Zen::Package::REGISTERED.key?(name.to_sym)
        raise(Zen::ValidationError, "The package #{name} already exists.")
      end
    end
  end # Package
end # Zen
