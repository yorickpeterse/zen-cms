require __DIR__('error/theme_error')
require __DIR__('theme/base')
require 'pathname'

#:nodoc:
module Zen
  ##
  # Themes in many ways are similar to plugins and packages but with a few
  # differences. Unlike packages themes aren't able to update the entire Ramaze
  # root, this prevents them from loading controllers and other classes unless
  # the developer updates these paths manually. However, themes can set the
  # following paths:
  #
  # * template_dir: the directory where all Liquid templates are located,
  #   always required.
  # * partial_dir: the directory where all Liquid partials are located.
  # * public_dir: the public directory containing assets such as CSS and
  #   Javascript files.
  # * migration_dir: themes can use migrations to automatically add the required
  #   fields to the database, this setting should point to the directory where
  #   all migrations are located.
  #
  # ## Adding Themes
  #
  # Just like plugins and packages a theme can be added by calling
  # Zen::Theme#add and passing a block to it. Once a theme has been loaded it
  # will *not* be used until the user sets it as the active theme in the
  # settings module.
  #
  # Example:
  #
  #     Zen::Theme.add do |theme|
  #       theme.author = 'Yorick Peterse'
  #       theme.name   = 'default'
  #     end
  #
  # @author Yorick Peterse
  # @since  0.2.4
  #
  module Theme
    ##
    # Hash containing all registered themes. The keys are the names of the
    # themes and the values instances of Zen::Theme::Base.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Registered = {}

    ##
    # Adds a new theme to Zen. Note that the theme won't be used unless it has
    # been set as the active theme in the settings package.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    #
    def self.add
      theme = Base.new

      yield theme

      # Validate the theme
      theme.validate
      theme.name = theme.name.to_sym

      # Do we have a public directory?
      if theme.respond_to?(:public_dir) and !theme.public_dir.nil?
        if !Ramaze.options.publics.include?(theme.public_dir)
          # Generate a relative path from ROOT to the theme
          to   = Pathname.new(theme.public_dir)
          from = Pathname.new(Zen.root)
          dir  = to.relative_path_from(from.realpath).to_s

          Ramaze.options.publics.push(dir)
        end
      end

      Registered[theme.name] = theme
    end

    ##
    # Retrieves a single theme for hte given identifier.
    #
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [String/Symbol] name The name of the theme to retrieve.
    # @return [Zen::Theme::Base]
    #
    def self.[](name)
      name = name.to_sym if name.class != Symbol

      if !Registered.key?(name)
        raise(Zen::ThemeError, "The theme #{name} doesn't exist.")
      end

      return Registered[name]
    end
  end # Theme
end # Zen
