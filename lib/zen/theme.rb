require 'pathname'

module Zen
  ##
  # Zen allows you to create templates and package them as themes using the
  # tools you already know such as Ruby, HTML and CSS. Once a theme has been
  # created it can be distributed using Rubygems or a different system, whatever
  # suits your taste.
  #
  # Themes consist out of a collection of templates. Templates are HTML files
  # that can contain Ruby code and use the template engine "Etanni" which is
  # provided by Ramaze itself. Etanni is a very simple (and very fast) template
  # engine that provides two types of tags, ``<?r ?>`` for statements (such as
  # if/else statements) and ``#{}`` for outputting data such as variables.
  # Here's a quick example:
  #
  #     <?r if @username.nil? ?>
  #     <p>Hello #{@username}!</p>
  #     <?r else ?>
  #     <p>Hello unknown user!</p>
  #     <?r end ?>
  #
  # Themes are typically installed as a Rubygem or are stored in the application
  # directory depending on whether or not you want to make it possible to share
  # the theme with other projects and/or users. While the process of creating
  # templates remain the same the directory structure will be different. For
  # Rubygems you should use the typical Rubygem directory structure. Assuming
  # our theme is called "test" the directory structure would look like the
  # following:
  #
  #     lib/
  #       |__ test.rb
  #       |__ test/
  #          |__ public/
  #          |__ templates/
  #             |__ partials/
  #             |__ pages/
  #             |__ foobar/
  #
  # On the other hand, if you're not planning on sharing the theme it's much
  # easier to use the following structure:
  #
  #     ROOT/
  #       |__ public/
  #       |
  #       |__ theme/
  #          |__ partials/
  #          |__ pages/
  #          |__ foobar/
  #          |__ partials/
  #          |__ test.rb
  #
  # In the end it doesn't really matter what structure you use as long as the
  # file "test.rb" contains the correct paths to the templates (more on that
  # later).
  #
  # ## Registering Themes
  #
  # An important part of developing a theme is telling Zen where it's located,
  # where the templates are and so on. This can be done by creating a Ruby file
  # (typically named after the template) in which you call ``Zen::Theme.add``.
  # This method takes a block that can be used to set various options. Currently
  # the following options are available:
  #
  # * name (required): the name of the theme (should be a symbol)
  # * author (required): the name of the person who developed the theme.
  # * about (required): a short description of the theme.
  # * templates (required): a path to the directory containing the templates for
  #   all sections.
  # * partials: a path to the directory containing all the partials that should
  #   be rendered when calling ``partial()``.
  # * public: a path to an extra public directory to use, useful when you're
  #   distributing your theme using Rubygems and want to ship it with a few CSS
  #   files.
  # * migrations: path to a directory containing all Sequel migrations for the
  #   theme. While not always needed this can be useful to automatically insert
  #   data into the database.
  #
  # An example call to ``Zen::Theme.add`` using these options:
  #
  #     Zen::Theme.add do |theme|
  #       theme.name      = :test
  #       theme.author    = 'Yorick Peterse'
  #       theme.about     = 'An example template'
  #       theme.templates = __DIR__('path/to/application/theme')
  #     end
  #
  # ## Template Structure
  #
  # Unlike other systems template directories and templates aren't bound to a
  # certain entity in a database or somewhere else. While it's recommended to
  # name your template directories the same as your sections you're free to use
  # whatever you like as lon as you remember that the structure of your
  # templates will affect your URLs (assuming you're not re-writing them using
  # Ramaze::Route or something else). For example, if you have a template
  # directory called "pages" and a template called "index.xhtml" the URL would
  # be ``/pages`` and ``pages/index``.  The names of your templates also don't
  # really matter although it's recommended to at least use the following
  # setup:
  #
  # * index.xhtml: template used to show an overview of something (e.g. a list
  #   of users), a homepage, etc.
  # * entry.xhtml: template used to show a single entitiy such as a blog post or
  #   a user.
  #
  # Again, you're free to use whatever you like as long as you make it clear
  # what you're doing.
  #
  # <div class="note todo">
  #     <p>
  #         <strong>Note</strong>: that if a template directory is requested but
  #         no template has been specified Zen will try to render the template
  #         index.xhtml so it's important to always have this template in place.
  #     </p>
  # </div>
  #
  # <div class="note deprecated">
  #     <p>
  #         <strong>Warning</strong>: Most likely your template will use files
  #         such as CSS and Javascript files. It's important to store these
  #         under their own namespace similar to assets used in the backend to
  #         prevent any collisions.
  #     </p>
  # </div>
  #
  # ## Retrieving Data
  #
  # Zen comes with a bunch of helpers that can be used to make it easy to
  # retrieve data such as section entries and comments. On top of that you can
  # also directly use all the classes provided by Zen since you're free to use
  # any Ruby in your templates. For example, say you want to retrieve a list
  # of entries in our ``index.xhtml`` template you could do something like the
  # following:
  #
  #     <?r entries = get_entries('blog', :limit => 50) ?>
  #
  #     <?r entries.each do |entry| ?>
  #     <article>
  #         <header>
  #             <h1>#{entry.title}</h1>
  #         </header>
  #
  #         #{entry.fields[:body]}
  #     </article>
  #     <?r end ?>
  #
  # <div class="note deprecated">
  #     <p>
  #         <strong>Warning</strong>: Don't run custom SQL queries inside your
  #         templates, create a helper, regular class or module if you want to
  #         retrieve custom data.
  #     </p>
  # </div>
  #
  # ## Template Partials
  #
  # Often you'll need to re-use an existing template multiple times. For
  # example, almost all templates will have some data inside the ``<head>`` tag
  # that will have pretty much the same markup and/or content in different
  # templates. Zen makes it possible this easy by using "partials". Partials are
  # simply templates stored in a specific directory (which is specified in the
  # "partials" option).
  #
  # There's no limitation as to what you can do with them except that they need
  # to be put into a particular directory. Once a partial is in place it can be
  # rendered using the ``partial()`` method. This method has the following
  # syntax:
  #
  #     partial(template[, variable => value])
  #
  # The first parameter is simply the name of the partial to render, the second
  # parameter is a hash containing data to copy into the partial. This hash can
  # be used to set data inside a partial such as the page's title. Example:
  #
  #     partial(:footer, :author => 'Yorick Peterse')
  #
  # In your ``footer.xhtml`` partial you can now do the following:
  #
  #     <p>Author: #{@author}</p>
  #
  # <div class="note todo">
  #     <p>
  #         <strong>Note</strong>: The variables set in the partial method are
  #         available as instance variables, not regular variables.
  #     </p>
  # </div>
  #
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
    # @since  0.2.5
    #
    REGISTERED = {}

    ##
    # Adds a new theme to Zen. Note that the theme won't be used unless it has
    # been set as the active theme in the settings package.
    #
    # @since  0.2.4
    #
    def self.add
      theme = self.new

      yield theme

      theme.validate

      REGISTERED[theme.name] = theme
    end

    ##
    # Retrieves a single theme for hte given identifier.
    #
    # @since  0.2.4
    # @param  [String/Symbol] name The name of the theme to retrieve.
    # @return [Zen::Theme::Base]
    #
    def self.[](name)
      name = name.to_sym if name.class != Symbol

      if !REGISTERED.key?(name)
        raise(Zen::ThemeError, "The theme #{name} doesn't exist.")
      end

      return REGISTERED[name]
    end

    ##
    # Sets the name of the theme.
    #
    # @since  0.3
    # @param  [#to_sym] name The name of the theme as a symbol.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Returns the description of the theme either in it's raw form or as a
    # translation.
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
    # Sets the public directory of the theme.
    #
    # @since  0.3
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
      if ::Zen::Theme::REGISTERED.key?(name.to_sym)
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
