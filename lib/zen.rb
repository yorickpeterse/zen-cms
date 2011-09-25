require 'ramaze'
require 'yaml'

Ramaze.setup(:verbose => false) do
  gem 'sequel'          , ['= 3.26']
  gem 'bcrypt-ruby'     , ['= 3.0.1'], :lib => 'bcrypt'
  gem 'sequel_sluggable', ['= 0.0.6']
  gem 'loofah'          , ['= 1.2.0']
  gem 'json'            , ['= 1.6.1']
  gem 'ramaze-asset'    , ['= 0.2.3'], :lib => 'ramaze/asset'
end

require __DIR__('zen/version')

##
# Main module for Zen, all other modules and classes will be placed inside this
# module. This module loads all required classes and is used for starting the
# application.
#
# @author Yorick Peterse
# @since  0.1
#
module Zen
  class << self
    # The database connection to use for Sequel.
    attr_accessor :database

    # Instance of Ramaze::Asset::Environment to use for all backend assets.
    attr_accessor :asset

    ##
    # Returns the current root directory.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    def root
      @root
    end

    ##
    # Sets the root directory and adds the path to Ramaze.options.roots.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    def root=(path)
      @root = path

      if !Ramaze.options.roots.include?(@root)
        Ramaze.options.roots.push(@root)
      end
    end

    ##
    # Prepares Zen for the party of it's life.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    def start
      if root.nil?
        raise('You need to specify a valid root directory in Zen.root')
      end

      Zen::Language.load('zen_general')

      require __DIR__('zen/model/settings')
      require __DIR__('zen/model/methods')

      # Set up Ramaze::Asset
      setup_assets

      # Load all packages
      require __DIR__('zen/package/all')

      # Load the global stylesheet and Javascript file if they're located in
      # ROOT/public/css/admin/global.css and ROOT/public/js/admin/global.js
      load_global_assets

      # Migrate all settings
      begin
        plugin(:settings, :migrate)
      rescue => e
        Ramaze::Log.warn(
          'Failed to migrate the settings, make sure the database ' \
            'table is up to date'
        )
      end

      require __DIR__('zen/plugin/markup/lib/markup')

      Zen.asset.build(:javascript)
      Zen.asset.build(:css)
    end

    private

    ##
    # Configures Ramaze::Asset and loads all the global assets.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    def setup_assets
      cache_path = File.join(root, 'public', 'minified')

      if !File.directory?(cache_path)
        Dir.mkdir(cache_path)
      end

      Zen.asset = Ramaze::Asset::Environment.new(
        :cache_path => cache_path,
        :minify     => Ramaze.options.mode === :live
      )

      Zen.asset.serve(
        :css,
        [
          'admin/css/zen/reset',
          'admin/css/zen/grid',
          'admin/css/zen/layout',
          'admin/css/zen/general',
          'admin/css/zen/forms',
          'admin/css/zen/tables',
          'admin/css/zen/buttons',
          'admin/css/zen/messages'
        ],
        :name => 'zen_core'
      )

      Zen.asset.serve(
        :javascript,
        [
          'admin/js/vendor/mootools/core',
          'admin/js/vendor/mootools/more',
          'admin/js/zen/lib/language',
          'admin/js/zen/lib/html_table',
          'admin/js/zen/index'
        ],
        :name => 'zen_core'
      )

      # Add all the asset groups.
      require __DIR__('zen/asset_groups')
    end

    ##
    # Loads a global CSS and JS file.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    def load_global_assets
      publics    = Ramaze.options.publics
      css_loaded = false
      js_loaded  = false

      publics.each do |p|
        p   = File.join(Zen.root, p)
        css = File.join(p, 'admin/css/global.css')
        js  = File.join(p, 'admin/js/global.js')

        if File.exist?(css) and css_loaded === false
          Zen.asset.serve(:css, ['admin/css/global'])
          css_loaded = true
        end

        if File.exist?(js) and js_loaded === false
          Zen.asset.serve(:javascript, ['admin/js/global'])
          js_loaded = true
        end
      end
    end
  end # class << self
end # Zen

Ramaze::Cache.options.names.push(:settings)
Ramaze::Cache.options.settings = Ramaze::Cache::LRU

# Load all classes/modules provided by Zen itself.
require __DIR__('zen/error')
require __DIR__('zen/validation')
require __DIR__('zen/plugin')
require __DIR__('zen/hook')
require __DIR__('zen/language')

# Load a set of modules into the global namespace
include Zen::Plugin::SingletonMethods
include Zen::Language::SingletonMethods

Ramaze::HelpersHelper.options.paths.push(__DIR__('zen'))
Ramaze.options.roots.push(__DIR__('zen'))
Zen::Language.options.paths.push(__DIR__('zen'))

require __DIR__('zen/package')
require __DIR__('zen/theme')
require __DIR__('zen/plugin/helper')

# Load all the base controllers
require __DIR__('zen/controller/base_controller')
require __DIR__('zen/controller/frontend_controller')
require __DIR__('zen/controller/admin_controller')
require __DIR__('zen/controller/main_controller')
require __DIR__('zen/controller/preview')
require __DIR__('zen/controller/translations')
