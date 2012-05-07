require 'pathname'
require 'ostruct'

module Zen
  ##
  # Zen allows you to create templates and package them as themes using the
  # tools you already know such as Ruby, HTML and CSS. Once a theme has been
  # created it can be distributed using Rubygems or by using an alternative
  # method.
  #
  # Themes consist out of two elements: template groups and templates. Template
  # groups are nothing more than directories of templates. Templates are files
  # that can contain HTML and Ruby code required for the presentation layer of
  # your application. These templates use Etanni, an engine that ships with
  # Ramaze. Etanni is quite simple to use and only uses the following two tags:
  #
  # * ``<?r ?>``: used for code statements (if, while, etc).
  # * ``#{}``: used for outputting the value of a variable, statement, method,
  #   and so on.
  #
  # A simple example of how to use these tags is the following:
  #
  #     <?r if @username.nil? ?>
  #     <p>Hello #{@username}!</p>
  #     <?r else ?>
  #     <p>Hello unknown user!</p>
  #     <?r end ?>
  #
  # ## Theme Structure
  #
  # A typical theme has a structure similar to the one used for organizing
  # Rubygems. This structure makes it easy to install themes via Rubygems and
  # load them just like any other gem by using ``require()``. An example of this
  # is the following:
  #
  #     lib/
  #       |__ test.rb
  #       |__ test/
  #          |__ public/
  #          |__ templates/
  #             |__ partials/
  #             |__ pages/
  #             |__ example/
  #
  # Lets assume the theme is called "test" and is available on Rubygems (under
  # the same name). In that case you can install it as following:
  #
  #     $ gem install test
  #
  # Once installed all you have to do is put the following line in your app.rb
  # file before calling ``Zen.start``:
  #
  #     require 'test'
  #
  # Once loaded you can go to the admin panel and set it as the active theme.
  #
  # While the Rubygems structure is great if you want to share a theme there are
  # a lot of cases where you don't want to do this. For example, if you're
  # creating a custom theme for a client you may not want to share it with
  # others. In that case the structure used by Rubygems is a bit complicated,
  # especially if there's only one theme for the website. A much more simplistic
  # way of organizing a theme would be to create a ``theme/`` directory in your
  # application root and put your theme in there. In this case you'd end up with
  # a file structure that looks like the following:
  #
  #     ROOT/
  #       |__ public/
  #       |
  #       |__ theme/
  #          |__ partials/
  #          |__ pages/
  #          |__ example/
  #          |__ test.rb
  #
  # Because the theme is located in the application root, which isn't added to
  # the load path, you'll have to load it in a slightly different way. Instead
  # of ``require 'test'`` you'd have to put the following code in your app.rb
  # file:
  #
  #     require File.expand_path('../theme/test', __FILE__) # All Rubies
  #     require_relative('theme/test')                      # Ruby >= 1.9
  #
  # Do keep in mind that putting a theme directly in the ``theme/`` directory
  # is only recommended if your application only has a single custom theme
  # available. If there are multiple ones you should change it to the following
  # instead:
  #
  #     ROOT/
  #       |__ public/
  #       |
  #       |__ theme/
  #          |__ test/
  #             |__ partials/
  #             |__ pages/
  #             |__ example/
  #             |__ test.rb
  #
  # <div class="note deprecated">
  #     <p>
  #         <strong>Warning:</strong> Most likely your template will use files
  #         such as CSS and Javascript files. It's important to store these
  #         under their own namespace similar to assets used in the backend to
  #         prevent any collisions.
  #     </p>
  # </div>
  #
  # ## Registering Themes
  #
  # In order to tell Zen about your themes, their templates, root directories
  # and so on they have to be registered. Registering a theme is done using
  # ``Zen::Theme.add``:
  #
  #     Zen::Theme.add do |t|
  #
  #     end
  #
  # This code should not go in files such as app.rb or configuration files,
  # instead it should go in a theme specific file. It is recommended to give
  # this file the same name as your theme as it makes it possible to load the
  # theme using Rubygems. For example, if the theme is called "test" then the
  # file would be called "test.rb".
  #
  # When registering a new theme you're required to set the following
  # attributes:
  #
  # <table class="table full">
  #     <thead>
  #         <tr>
  #             <th>Attribute</th>
  #             <th>Description</th>
  #         </tr>
  #     </thead>
  #     <tbody>
  #         <tr>
  #             <td>name</td>
  #             <td>The name of the theme as a symbol.</td>
  #         </tr>
  #         <tr>
  #             <td>auhtor</td>
  #             <td>The name of the author of the theme.</td>
  #         </tr>
  #         <tr>
  #             <td>about</td>
  #             <td>A short description of the theme.</td>
  #         </tr>
  #         <tr>
  #             <td>templates</td>
  #             <td>
  #                 Path to the directory containing the templates of the
  #                 theme.
  #             </td>
  #         </tr>
  #     </tbody>
  # </table>
  #
  # Optionally you can also specify the following attributes:
  #
  # <table class="table full">
  #     <thead>
  #         <tr>
  #             <th>Attribute</th>
  #             <th>Description</th>
  #         </tr>
  #     </thead>
  #     <tbody>
  #         <tr>
  #             <td>partials</td>
  #             <td>Path to a directory containing template partials.</td>
  #         </tr>
  #         <tr>
  #             <td>public</td>
  #             <td>
  #                 Path to the public directory of the theme. This attribute is
  #                 useful when you're distributing CSS and Javascript files (or
  #                 other static files) with your theme.
  #             </td>
  #         </tr>
  #         <tr>
  #             <td>migrations</td>
  #             <td>Directory containing Sequel migrations for the theme.</td>
  #         </tr>
  #         <tr>
  #             <td>default_template_group</td>
  #             <td>
  #                 The name of the default template group to use, set to
  #                 "default" by default.
  #             </td>
  #         </tr>
  #         <tr>
  #             <td>env</td>
  #             <td>
  #                 An instance of OpenStruct that can be used for storing
  #                 arbitrary data (such as an asset manager).
  #             </td>
  #         </tr>
  #     </tbody>
  # </table>
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
  # ## URL Mapping
  #
  # Template groups and templates are directly mapped to URIs. The first segment
  # is the template group to use, the second the template name and all following
  # parameters are ignored (but still available in your templates). This means
  # that if a user requests the URI ``/pages/entry/10`` this will map to the
  # template group "pages" and the template "entry.xhtml". If a specified
  # template group/template doesn't exist Zen will render a special template
  # called "404.xhtml" (this template should be located in the same directory as
  # your template groups).
  #
  # If only a template group is specified Zen will render the template
  # "index.xhtml", therefor you should make sure this template always exists.
  #
  # Some examples:
  #
  #     GET /pages/entry/hello-world => /pages/entry.xhtml
  #     GET /pages/example           => /404.xhtml (if "example" doesn't exist)
  #     GET /pages                   => /pages/index.xhtml
  #
  # Templates have access to the special instance variable ``@request_uri``.
  # This variable is an array that contains the template group, the template and
  # all additional parameters. In the case of the examples above you'd end up
  # with the following values for this array:
  #
  #     GET /pages/entry/hello-world => ['pages', 'entry', 'hello-world']
  #     GET /pages/example           => ['pages', 'example']
  #     GET /pages                   => ['pages', 'index']
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
  #         <strong>Warning:</strong> Don't run custom SQL queries inside your
  #         templates, create a helper, regular class or module if you want to
  #         retrieve custom data.
  #     </p>
  # </div>
  #
  # ## Template Partials
  #
  # Often you'll need to reuse an existing template multiple times. For
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
  #     partial(template[, :variable => value])
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
  #         <strong>Note:</strong> The variables set in the partial method are
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

    # The name of the default template group to use.
    attr_writer :default_template_group

    # Instance of OpenStruct that can be used for storing custom data such as an
    # instance of ``Ramaze::Asset::Environment``.
    attr_reader :env

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
    # Retrieves a single theme for the given identifier.
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
    # Creates a new instance of the theme.
    #
    # @since 12-02-2012
    #
    def initialize
      @env = OpenStruct.new
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
    # Returns the name of the theme as either plain text or an anchor tag if the
    # URL attribute is set.
    #
    # @since  19-11-2011
    # @return [String]
    #
    def formatted_name
      if url
        return '<a href="%s" title="%s" class="icon external">%s</a>' % [
          url,
          name,
          name
        ]
      else
        return name
      end
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
    # Returns the name of the default template group or "default" if no custom
    # name is set.
    #
    # @since  22-11-2011
    # @return [String]
    #
    def default_template_group
      return @default_template_group || 'default'
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
  end # Theme
end # Zen
