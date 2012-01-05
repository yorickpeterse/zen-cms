require 'ramaze'

Ramaze.setup(:verbose => false) do
  gem 'sequel'      , ['~> 3.31.0']
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
    # Sanitizes the string by escaping all Etanni template tags in it so that
    # they aren't executed. Optionally this method can also remove all dangerous
    # HTML using Loofah.
    #
    # @since  03-01-2012
    # @param  [String] input The input string to sanitize.
    # @param  [TrueClass|FalseClass] clean_html When set to true certain HTML
    #  elements will be removed using Loofah.
    # @return [String] The sanitized string.
    #
    def sanitize(input, clean_html = false)
      return input unless input.is_a?(String)

      # Cheap way of escaping the template tags.
      input = input.gsub('<?r', '\<\?r') \
        .gsub('?>', '\?\>') \
        .gsub('#{', '\#\{') \
        .gsub('}', '\}')

      if clean_html == true
        input = Loofah.fragment(input).scrub!(:whitewash).scrub!(:nofollow).to_s
      end

      return input
    end

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
    # Prepares Zen for the party of it's life.
    #
    # @since 0.3
    # @event pre_start Event that is fired before starting Zen.
    # @event post_start Event that is fired after all packages have been loaded,
    #  the cache has been set up, etc. This event is called just before building
    #  all the assets.
    #
    def start
      raise('No valid root directory specified in Zen.root') if root.nil?

      Zen::Event.call(:pre_start)

      # Set up Ramaze::Cache manually. This makes it possible for the language
      # files to cache their data in the custom cache without having to wait for
      # Ramaze to set it up.
      Ramaze::Cache.setup
      Ramaze.options.setup.delete(Ramaze::Cache)

      require 'zen/model/init'
      require 'zen/model/methods'
      require 'zen/package/all'

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
