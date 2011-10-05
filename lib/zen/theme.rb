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
  # * templates: the directory where all Liquid templates are located, always
  #   required.
  # * partials: the directory where all Liquid partials are located.
  # * public: the public directory containing assets such as CSS and Javascript
  #   files.
  # * migrations: themes can use migrations to automatically add the required
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
  #       theme.name   = :default
  #     end
  #
  # @author Yorick Peterse
  # @since  0.2.4
  #
  class Theme
    include Zen::Validation

    # The name of the theme
    attr_reader :name

    # The author of the theme
    attr_accessor :author

    # A small description of the theme
    attr_writer :about

    # The URL to the theme's homepage
    attr_accessor :url

    # Path to the directory containing all the templates.
    attr_accessor :templates

    # Path to the directory containing all template partials.
    attr_accessor :partials

    # Path to the directory containing all migrations for the theme.
    attr_accessor :migrations

    # Path to the public directory containing assets and such.
    attr_reader :public

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
      theme = self.new

      yield theme

      theme.validate

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

    ##
    # Sets the name of the theme.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] name The name of the theme as a symbol.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Returns the description of the theme either in it's raw form or as a
    # translation.
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
    # Sets the public directory of the theme.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [String] dir The public directory.
    #
    def public=(dir)
      @public = dir

      if !Ramaze.options.publics.include?(@public)
        # Generate a relative path from ROOT to the theme
        to   = Pathname.new(@public)
        from = Pathname.new(Zen.root)
        dir  = to.relative_path_from(from.realpath).to_s

        Ramaze.options.publics.push(dir)
      end
    end

    ##
    # Validates all attributes of this class.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    def validate
      validates_presence([:name, :author, :about, :templates])

      validates_filepath(:templates)

      [:partials, :public, :migrations].each do |m|
        if !send(m).nil?
          validates_filepath(m)
        end
      end

      # Check if the theme hasn't already been registered
      if ::Zen::Theme::Registered.key?(name.to_sym)
        raise(
          ::Zen::ValidationError,
          "The theme #{name} has already been registered."
        )
      end
    end

    # Aliases to keep Zen backwards compatible. These aliases will be removed in
    # Zen 0.3.
    alias :template_dir  :templates
    alias :template_dir= :templates=

    alias :partial_dir   :partials
    alias :partial_dir=  :partials=

    alias :migration_dir  :migrations
    alias :migration_dir= :migrations=

    alias :public_dir  :public
    alias :public_dir= :public=
  end # Theme
end # Zen
