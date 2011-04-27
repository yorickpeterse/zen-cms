require 'ramaze/gestalt'

#:nodoc:
module Zen
  ##
  # The Asset module is a module used to register what Javascript files and stylesheets
  # should be loaded for the current request. This can be very useful if you want to add
  # a widget to all pages or override a certain stylesheet.
  #
  # ## Adding Assets
  #
  # Assets can be added by calling either Zen::Asset.stylesheet or Zen::Asset.javascript.
  # Both take an array of files and a hash with some configuration options, for more info
  # on the exact usage and all the available parameters see the individual methods. Here
  # are a few quick examples of loading files:
  #
  #     # Load 3 Javascript files of which 2 will be loaded globally
  #     Zen::Asset.javascript(
  #       ['mootools/core', 'mootools/more'], :global => true,
  #     )
  #
  #     Zen::Asset.javascript(['application'], :controller => self)
  #
  #     # Do the same with a few stylesheets
  #     Zen::Asset.stylesheet(['admin/css/forms'], :global => true)
  #     Zen::Asset.stylesheet(['style'], :controller => self)
  #
  # ## Customizing Options
  #
  # This module uses Innate::Optioned to provide a few options that can be changed. The
  # following options are available:
  #
  # * prefix: The global prefix to use for all assets, set to "admin" by default.
  # * javascript_prefix: The prefix to use for all Javascript files on top of the global
  # prefix.
  # * stylesheet_prefix: Similar to the javascript_prefix option but for stylesheets.
  #
  # ## Building Assets
  #
  # Building assets shouldn't be required as Zen already does this but if you happen to 
  # need it you can build the files as following:
  #
  #     Zen::Asset.build(:stylesheet)
  #     Zen::Asset.build(:javascript)
  #
  # ## Controller Usage
  #
  # While this module can be called by any other piece of code the class 
  # Zen::Controller::AdminController provides shortcuts to Zen::Asset.javascript and 
  # Zen::Asset.stylesheet. These shortcuts work identical but are defined as class methods
  # and thus can be used inside your class declaration:
  #
  #     class Something < Zen::Controller::AdminController
  #       stylesheet ['reset'], :global => true
  #     end
  #
  # @author Yorick Peterse
  # @since  0.2.5
  #
  module Asset
    include ::Innate::Optioned

    class << self
      include ::Innate::Trinity
    end

    options.dsl do
      o 'Prefix for both Javascript files and stylesheets', :prefix           , 'admin'
      o 'Prefix for Javascript files on top of :prefix'   , :javascript_prefix, 'js'
      o 'Prefix for stylesheets on top of :prefix'        , :stylesheet_prefix, 'css'
    end

    ##
    # Hash containing all the global and controller specific stylesheets that have to be
    # loaded when calling build_stylesheets.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Stylesheets = {
      :global => []
    }

    ##
    # Hash containing all the global and controller specific stylesheets to load when
    # calling build_javascripts.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    Javascripts = {
      :global => []
    }

    ##
    # Registers the given Javascripts files so that they're either loaded for the
    # current action or for all actions. Note that the first argument of this method
    # should always be an array.
    #
    # @example
    #  # Loads /admin/js/users/access_rules.js for the current action only
    #  Zen::Asset.javascript ['users/access_rules']
    #
    #  # This would load the file globally
    #  Zen::Asset.javascript ['users/access_rules'], :global => true
    #
    # @author Yorick Peterse
    # @since  0.2.5
    # @param  [Array] files An array of Javascript files (without their extensions) to
    # load relatively to the root of the application (/).
    # @param  [Hash] options A hash containing additional options.
    # @option options [TrueClass] :global When set to true the specified files will be
    # loaded globally rather than just for the current action.
    # @option options [String/Symbol] controller The name of the controller for which
    # the specified files should be loaded.
    #
    def self.javascript(files, options = {})
      options = {
        :prefix => File.join('/', self.options.prefix, self.options.javascript_prefix),
        :type   => :javascript
      }.merge(options)

      process(files, options)
    end

    ##
    # Registers a number of stylesheets that can either be loaded globally or for the
    # current action.
    #
    # @example
    #  Zen::Asset.stylesheet ['foobar/admin_template'], :global => true
    #
    # @author Yorick Peterse
    # @since  0.2.5
    # @param  [Array] files A list of stylesheets (without their extensions) to load.
    # @param  [Hash] options A hash containing additional options to use.
    # @option options [TrueClass] :global When set to true all the specified stylesheets
    # will be loaded globally rather than just for the current action.
    # @option options [String/Symbol] controller The name of the controller for which
    # the specified files should be loaded. 
    #
    def self.stylesheet(files, options = {})
      options = {
        :prefix => File.join('/', self.options.prefix, self.options.stylesheet_prefix),
        :type   => :stylesheet
      }.merge(options)

      process(files, options)
    end

    ##
    # Builds either all Javascript files or stylesheets. This method will load both the
    # global and action specific files.
    #
    # @example
    #  # Build the HTML tags for all stylesheets
    #  Zen::Asset.build(:stylesheet)
    #
    #  # Build the HTML tags for all Javascript files
    #  Zen::Asset.build(:javascript)
    #
    # @author Yorick Peterse
    # @since  0.2.5
    # @param  [Symbol] type The type of assets to build.
    # @return [String] The HTML tags for all the assets.
    # 
    def self.build(type)
      type       = type.to_sym
      attrs      = {}
      controller = action.node.to_s.to_sym
      gestalt    = Ramaze::Gestalt.new

      # Set the basic elements of the tag
      if type === :stylesheet
        tag         = :link
        value       = :href
        attrs[:rel] = 'stylesheet'
        files       = Stylesheets
      else
        tag   = :script
        value = :src
        files = Javascripts
      end

      # Get all the files to build
      if !files[controller].nil?
        files = files[:global] + files[controller]
      else
        files = files[:global]
      end

      # Build the tags
      files.each do |f|
        tag_attrs = {
          value => f
        }.merge(attrs)

        if type === :javascript
          gestalt.send(tag, '', tag_attrs)
        else
          gestalt.send(tag, tag_attrs)
        end
      end

      return gestalt.to_s
    end

    private

    ##
    # Stores the given files in the correct hash based on the specified options.
    #
    # @example
    #  process(['foobar', 'baz'], :global => false, :type => :javascript, :prefix => 'js')
    #
    # @author Yorick Peterse
    # @since  0.2.5
    # @param  [Array] files An array of files to load.
    # @param  [Hash] options A hash containing all the required options.
    # @option options [TrueClass] :global Specifies that all the files should be loaded
    # globally.
    # @option options [Symbol] :type The type of asset that's loaded, can either be
    # :javascript or :stylesheet.
    # @option options [String] :prefix The prefix to use for all the assets.
    # @option options [TrueClass] :global
    # @option options [Symbol/String] :controller
    #
    def self.process(files, options)
      # Determine whether the files should be loaded globally
      if options.key?(:global) and options[:global] === true
        key = :global
      else
        key = options[:controller].to_s.to_sym
      end

      # Determine where to save the data
      if options[:type] === :javascript
        save = Javascripts
        ext  = '.js'
      else
        save = Stylesheets
        ext  = '.css'
      end

      # Add all the files
      files.each do |f|
        f           = f.to_s + ext
        f           = File.join(options[:prefix], f)
        save[key] ||= []

        if !save[key].include?(f)
          save[key].push(f)
        end
      end
    end

  end
end
