require __DIR__('error/theme_error')
require 'pathname'

#:nodoc:
module Zen
  ##
  # Themes in many ways are similar to plugins and packages but with a few differences.
  # Unlike packages themes aren't able to update the entire Ramaze root, this prevents
  # them from loading controllers and other classes unless the developer updates these
  # paths manually. However, themes can set the following paths:
  #
  # * template_dir: the directory where all Liquid templates are located, always required.
  # * partial_dir: the directory where all Liquid partials are located.
  # * public_dir: the public directory containing assets such as CSS and Javascript files.
  # * migration_dir: themes can use migrations to automatically add the required fields to
  # the database, this setting should point to the directory where all migrations are
  # located.
  #
  # ## Adding Themes
  #
  # Just like plugins and packages a theme can be added by calling Zen::Theme#add and
  # passing a block to it. Once a theme has been loaded it will *not* be used until the
  # user sets it as the active theme in the settings module.
  #
  # Example:
  #
  #     Zen::Theme.add do |theme|
  #       theme.author     = 'Yorick Peterse'
  #       theme.name       = 'Default'
  #       theme.version    = '0.1'
  #       theme.identifier = 'com.yorickpeterse.theme.default'
  #     end
  #
  # The "identifier" key is very important and just like packages and plugins it should
  # always stay the same once it has been set.
  #
  # ## Identifiers
  #
  # Theme identifiers should be in the following format:
  #
  #     com.VENDOR.theme.NAME
  #
  # For example:
  #
  #     com.yorickpeterse.theme.fancy_blog
  #
  # @author Yorick Peterse
  # @since  0.2.4
  # @attr_reader [Array] themes Array of all installed themes.
  #
  module Theme
    class << self
      attr_reader :themes
    end

    ##
    # Adds a new theme to Zen. Note that the theme won't be used unless it has been set
    # as the active theme in the settings package.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @yield  [theme] Struct object containing all getter/setters for each theme.
    #
    def self.add
      @themes ||= {}

      required = [:name, :author, :version, :about, :identifier, :template_dir]
      theme    = Zen::StrictStruct.new(
        :name, :author, :version, :about, :url, :identifier, :template_dir, :partial_dir,
        :public_dir, :migration_dir
      ).new

      yield theme

      # Check if all required items have been set
      theme.validate(required) do |k|
        raise(Zen::ThemeError, "The following theme key is missing: #{k}")
      end

      # Validate all paths set
      [:template_dir, :partial_dir, :public_dir, :migration_dir].each do |k|
        # Only validate the path if it has been set
        if theme.respond_to?(k) and !theme.send(k).nil? and !theme.send(k).empty?
          if !File.exist?(theme.send(k))
            raise(Zen::ThemeError, "The path #{k} doesn't exist.")
          end
        end
      end

      # Do we have a public directory?
      if theme.respond_to?(:public_dir) and !theme.public_dir.nil?
        if !Ramaze.options.publics.include?(theme.public_dir)
          # Generate a relative path from ROOT to the theme
          to   = Pathname.new(theme.public_dir)
          from = Pathname.new(Zen.options.root)
          dir  = to.relative_path_from(from.realpath).to_s

          Ramaze.options.publics.push(dir)
        end
      end

      if !@themes[theme.identifier].nil?
        raise(Zen::ThemeError, "The theme #{theme.name} already exists.")
      end

      @themes[theme.identifier] = theme
    end

    ##
    # Retrieves a single theme for hte given identifier.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [String] ident The identifier of the theme.
    # @return [Struct] Instance of the theme.
    #
    def self.[](ident)
      if @themes.nil?
        raise(Zen::ThemeError, "No themes have been added.")
      end

      if !@themes[ident]
        raise(Zen::ThemeError, "The theme #{ident} doesn't exist.")
      end

      return @themes[ident]
    end

  end
end
