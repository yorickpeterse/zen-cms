require 'ramaze/gestalt'
require __DIR__('package/menu')

#:nodoc:
module Zen
  ##
  # Module used for registering extensions and themes, setting their details and
  # the whole shebang. Packages follow the same directory structure as Rubygems
  # and can actually be installed using either Rubygems or by storing them in a
  # custom directory. As long as you require the correct file you're good to go.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  class Package
    include Zen::Validation

    ##
    # Hash containing all the registered packages. The keys of this hash are the
    # names of all packages and the values the instances of Zen::Package::Base.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Registered = {}

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
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Block|Proc] A block (or anything that can be converted to a
      #  Proc) containing the details of teh package.
      #
      def add(&block)
        package = self.new

        yield(package)
        package.validate

        Registered[package.name] = package
      end

      ##
      # Retrieves the package for the given name.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def [](name)
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
      # Builds the entire navigation menu for all packages.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [String] html_class An HTML class to apply to the <ul> element.
      # @param  [Array] permissions An array of permissions for the current
      #  user.
      # @return [String]
      #
      def build_menu(html_class = 'navigation', permissions = [])
        g = Ramaze::Gestalt.new

        g.ul(:class => html_class) do
          # Sort the hash
          keys = Registered.keys.sort

          keys.each do |key|
            g.out << Registered[key].menu.html(permissions)
          end
        end

        return g.to_s
      end
    end # class << self

    ##
    # Sets the name of the package. The name of a package should be a short and
    # unique name. A human readable version can be set using title=().
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] name The name of the package.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Sets the title of the package.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [String] title The title or language key of the package.
    #
    def title=(title)
      @title = title
    end

    ##
    # Returns the title of the package. This method will try to translate it and
    # fall back to the original value in case the language key doesn't exist.
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
    # Sets the description of the package.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [String] about The description of the package.
    #
    def about=(about)
      @about = about
    end

    ##
    # Tries to translate the description and returns it.
    #
    # @author Yorick Peterse
    # @since  0.2.9
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
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [String] root The path to the root directory.
    #
    def root=(root)
      @root = root

      if !Ramaze.options.roots.include?(@root)
        Ramaze.options.roots << @root
      end

      if !Zen::Language.options.paths.include?(@root)
        Zen::Language.options.paths << @root
      end

      if !Ramaze::HelpersHelper.options.paths.push.include?(@root)
        Ramaze::HelpersHelper.options.paths << @root
      end
    end

    ##
    # Sets all the navigation items for the package. Sub items can be specified
    # by calling this method and passing a block to it.
    #
    # @author Yorick Peterse
    # @since  0.2.9
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
    # @author Yorick Peterse
    # @since  0.2.9
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
    # @author Yorick Peterse
    # @since  0.2.9
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
    # @author Yorick Peterse
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :title, :author, :about, :root])

      validates_filepath(:root)
      validates_filepath(:migrations) unless migrations.nil?

      # Check if the package hasn't been registered yet
      if Zen::Package::Registered.key?(name.to_sym)
        raise(Zen::ValidationError, "The package #{name} already exists.")
      end
    end
  end # Package
end # Zen
