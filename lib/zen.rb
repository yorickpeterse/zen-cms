require 'ramaze'

Ramaze.setup(:verbose => false) do
  gem 'sequel'      , ['~> 3.28.0']
  gem 'bcrypt-ruby' , ['~> 3.0.1'], :lib => 'bcrypt'
  gem 'loofah'      , ['~> 1.2.0']
  gem 'ramaze-asset', ['~> 0.2.3'], :lib => 'ramaze/asset'
end

unless $LOAD_PATH.include?(__DIR__)
  $LOAD_PATH.unshift(__DIR__)
end

##
# Main module for Zen, all other modules and classes will be placed inside this
# module.
#
# @since  0.1
#
module Zen
  class << self
    # The database connection to use for Sequel.
    attr_accessor :database

    # Instance of Ramaze::Asset::Environment to use for all backend assets.
    attr_accessor :asset

    # The root directory of the application.
    attr_reader :root

    ##
    # Sets the root directory and adds the path to Ramaze.options.roots.
    #
    # @since  0.3
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
    # @since  0.3
    #
    def start
      if root.nil?
        raise('You need to specify a valid root directory in Zen.root')
      end

      # Set up Ramaze::Cache manually. This makes it possible for the langauge
      # files to cache their data in the custom cache without having to wait for
      # Ramaze to set it up.
      Ramaze::Cache.setup
      Ramaze.options.setup.delete(Ramaze::Cache)

      require 'zen/model/init'
      require 'zen/model/methods'

      setup_assets

      require 'zen/package/all'

      # Load the global stylesheet and Javascript file if they're located in
      # ROOT/public/css/admin/global.css and ROOT/public/js/admin/global.js
      load_global_assets

      # Migrate all settings
      begin
        Settings::Setting.migrate
      rescue => e
        Ramaze::Log.warn(
          'Failed to migrate the settings, make sure the database ' \
            'table is up to date and that you executed rake db:migrate.'
        )
      end

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
          'admin/css/zen/reset',
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
          'admin/js/zen/lib/base',
          'admin/js/zen/lib/html_table',
          'admin/js/zen/index'
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
        css = File.join(p, 'admin', 'css', 'global.css')
        js  = File.join(p, 'admin', 'js', 'global.js')

        if File.exist?(css) and css_loaded == false
          Zen.asset.serve(:css, ['admin/css/global'])
          css_loaded = true
        end

        if File.exist?(js) and js_loaded == false
          Zen.asset.serve(:javascript, ['admin/js/global'])
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
require 'zen/languages'

Ramaze::HelpersHelper.options.paths.push(__DIR__('zen'))
Ramaze.options.roots.push(__DIR__('zen'))
Zen::Language.options.paths.push(__DIR__('zen/language'))

include Zen::Language::SingletonMethods

require 'zen/markup'
require 'zen/package'
require 'zen/theme'

# Load all the base controllers
require 'zen/controller/base_controller'
require 'zen/controller/frontend_controller'
require 'zen/controller/admin_controller'
require 'zen/controller/main_controller'
require 'zen/controller/preview'
require 'zen/controller/translations'
