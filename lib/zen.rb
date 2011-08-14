require 'rubygems'
require 'ramaze'
require 'yaml'

Ramaze.setup(:verbose => false) do
  gem 'sequel'          , ['~> 3.26']
  gem 'bcrypt-ruby'     , ['~> 2.1.4'], :lib => 'bcrypt'
  gem 'sequel_sluggable', ['~> 0.0.6']
  gem 'loofah'          , ['~> 1.2.0']
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
      Zen::Language.load('zen_general')

      require __DIR__('zen/model/settings')
      require __DIR__('zen/model/methods')

      # Load all packages
      require __DIR__('zen/package/all')

      # Load the global stylesheet and Javascript file if they're located in
      # ROOT/public/css/admin/global.css and ROOT/public/js/admin/global.js
      publics = ::Ramaze.options.publics

      publics.each do |p|
        p   = File.join(Zen.root, p)
        css = File.join(p, 'admin/css/global.css')
        js  = File.join(p, 'admin/js/global.js')

        Zen::Asset.stylesheet(['global'], :global => true) if File.exist?(css)
        Zen::Asset.javascript(['global'], :global => true) if File.exist?(js)
      end

      # Migrate all settings
      begin
        plugin(:settings, :migrate)
      rescue => e
        Ramaze::Log.warn(
          'Failed to migrate the settings, make sure the database ' + \
            'table is up to date'
        )
      end

      require __DIR__('zen/plugin/markup/lib/markup')
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
require __DIR__('zen/asset')

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
