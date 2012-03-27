require 'ramaze'
require 'json'

Ramaze.setup(:verbose => false) do
  gem 'sequel'      , ['~> 3.33.0']
  gem 'bcrypt-ruby' , ['~> 3.0.1'], :lib => 'bcrypt'
  gem 'loofah'      , ['~> 1.2.0']
  gem 'ramaze-asset', ['~> 0.2.3'], :lib => 'ramaze/asset'
end

$:.unshift(__DIR__) unless $:.include?(__DIR__)

##
# Main module for Zen, all other modules and classes will be placed inside this
# module.
#
# @since  0.1
#
module Zen
  ##
  # Array containing all the translations that should be made available to the
  # Javascript code.
  #
  # @since 19-02-2012
  #
  JAVASCRIPT_TRANSLATIONS = [
    'zen_general.buttons.bold',
    'zen_general.buttons.italic',
    'zen_general.buttons.link',
    'zen_general.buttons.ul',
    'zen_general.buttons.ol',
    'zen_general.buttons.preview',
    'zen_general.buttons.close',
    'zen_general.datepicker.select_a_time',
    'zen_general.datepicker.use_mouse_wheel',
    'zen_general.datepicker.time_confirm_button',
    'zen_general.datepicker.apply_range',
    'zen_general.datepicker.cancel',
    'zen_general.datepicker.week'
  ]

  class << self
    # The database connection to use for Sequel.
    attr_reader :database

    # Instance of Ramaze::Asset::Environment to use for all backend assets.
    attr_accessor :asset

    # The root directory of the application.
    attr_reader :root

    ##
    # Sets the root directory and adds the path to Ramaze.options.roots. Once
    # set this method sets up the global assets and loads all asset groups that
    # ship with Zen.
    #
    # @since  0.3
    #
    def root=(path)
      raise('You can only set Zen.root once') unless root.nil?

      @root = path

      if !Ramaze.options.roots.include?(@root)
        Ramaze.options.roots.push(@root)
      end

      setup_assets
      load_global_assets
    end

    ##
    # Sets the database connection to use and loads the core packages provided
    # by Zen.
    #
    # @since 27-03-2012
    #
    def database=(database)
      @database = database

      require 'zen/model/init'
      require 'zen/model/methods'
      require 'zen/package/all'
    end

    ##
    # Prepares Zen for the party of its life.
    #
    # @since 0.3
    # @event post_start Event that is fired after all packages have been loaded,
    #  the cache has been set up, etc. This event is called at the very end of
    #  the method.
    #
    def start
      raise('No valid root directory specified in Zen.root') if root.nil?

      # Set up Ramaze::Cache manually. This makes it possible for the language
      # files to cache their data in the custom cache without having to wait for
      # Ramaze to set it up.
      Ramaze::Cache.setup
      Ramaze.options.setup.delete(Ramaze::Cache)

      Zen::Event.call(:post_start)

      Zen.asset.build(:javascript)
      Zen.asset.build(:css)
    end

    private

    ##
    # Configures Ramaze::Asset and loads all the global assets.
    #
    # @since  0.3
    #
    def setup_assets
      cache_path = File.join(root, 'public', 'minified')

      if !File.directory?(cache_path)
        Dir.mkdir(cache_path)
      end

      Zen.asset = Ramaze::Asset::Environment.new(
        :cache_path => cache_path,
        :minify     => Ramaze.options.mode == :live
      )

      Zen.asset.serve(
        :css,
        [
          'admin/zen/css/reset',
          'admin/zen/css/layout',
          'admin/zen/css/general',
          'admin/zen/css/forms',
          'admin/zen/css/tables',
          'admin/zen/css/buttons',
          'admin/zen/css/messages'
        ],
        :name => 'zen_core'
      )

      Zen.asset.serve(
        :javascript,
        [
          'admin/mootools/js/core',
          'admin/mootools/js/more',
          'admin/zen/js/lib/base',
          'admin/zen/js/lib/events',
          'admin/zen/js/lib/html_table',
          'admin/zen/js/lib/autosave',
          'admin/zen/js/lib/form',
          'admin/zen/js/index'
        ],
        :name => 'zen_core'
      )

      require 'zen/asset_groups'
    end

    ##
    # Loads a global CSS and JS file.
    #
    # @since  0.3
    #
    def load_global_assets
      publics    = Ramaze.options.publics
      css_loaded = false
      js_loaded  = false

      publics.each do |p|
        p   = File.join(Zen.root, p)
        css = File.join(p, 'admin/zen/css/global.css')
        js  = File.join(p, 'admin/zen/js/global.js')

        if File.exist?(css) and css_loaded == false
          Zen.asset.serve(:css, ['admin/zen/css/global'])
          css_loaded = true
        end

        if File.exist?(js) and js_loaded == false
          Zen.asset.serve(:javascript, ['admin/zen/js/global'])
          js_loaded = true
        end
      end
    end
  end # class << self
end # Zen

require __DIR__('vendor/sequel_sluggable')
require 'zen/version'

Ramaze::Cache.options.names.push(:settings, :translations)
Ramaze::Cache.options.settings     = Ramaze::Cache::LRU
Ramaze::Cache.options.translations = Ramaze::Cache::LRU

# Load all classes/modules provided by Zen itself.
require 'zen/error'
require 'zen/validation'
require 'zen/language'
require 'zen/event'
require 'zen/model/helper'
require 'zen/model/plugin/events'
require 'zen/languages'

Ramaze::HelpersHelper.options.paths.push(__DIR__('zen'))
Ramaze.options.roots.push(__DIR__('zen'))
Zen::Language.options.paths.push(__DIR__('zen/language'))

include Zen::Language::SingletonMethods

require 'zen/markup'
require 'zen/package'
require 'zen/theme'
require 'zen/security'
require 'zen/migrator'

# Load all the base controllers
require 'zen/controller/base_controller'
require 'zen/controller/frontend_controller'
require 'zen/controller/admin_controller'
require 'zen/controller/main_controller'
require 'zen/controller/preview'
