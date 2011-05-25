require 'sequel'
require 'ramaze'
require 'bcrypt'
require 'json'
require 'sequel_sluggable'
require 'yaml'
require 'loofah'
require __DIR__('zen/version')

##
# Main module for Zen, all other modules and classes will be placed inside this module.
# This module loads all required classes and is used for starting the application.
#
# @author Yorick Peterse
# @since  0.1
#
module Zen
  # Update several paths so we can load helpers/layouts from the Zen gem
  Innate::HelpersHelper.options.paths.push(__DIR__('zen'))
  Ramaze.options.roots.push(__DIR__('zen'))

  class << self
    ##
    # Variable that will contain a database connection that was established using
    # Sequel.connect.
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    attr_accessor :database

    ##
    # Hash containing all system settings.
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    attr_accessor :settings

    ##
    # String containing the path to the root directory of the Zen application.
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    attr_accessor :root

    ##
    # Loads the database and the required models.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def init
      @settings ||= {}

      # Initialize the database
      Zen::Language.load('zen_general')

      require __DIR__('zen/model/settings')
      require __DIR__('zen/model/methods')

      # Load the global stylesheet and Javascript file if they're located in
      # ROOT/public/css/admin/global.css and ROOT/public/js/admin/global.js
      publics = ::Ramaze.options.publics

      publics.each do |p|
        p   = File.join(Zen.root, p)
        css = File.join(p, 'admin/css/global.css')
        js  = File.join(p, 'admin/js/global.js')

        # Load the CSS file if it's there
        if File.exist?(css)
          ::Zen::Asset.stylesheet(['global'], :global => true)
        end

        # Load the JS file if it's there
        if File.exist?(js)
          ::Zen::Asset.javascript(['global'], :global => true)
        end
      end
    end

    ##
    # Method executed after everything has been set up and loaded.
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    def post_init
      # Migrate all settings
      begin
        plugin(:settings, :migrate)
      rescue
        Ramaze::Log.warn(
          "Failed to migrate the settings, make sure the database table is up to date"
        )
      end

      begin
        ::Settings::Model::Setting.get_settings.each do |k, v|
          @settings[k] = v
        end
      rescue => e
        Ramaze::Log.warn(
          "Failed to retrieve the settings, are you sure the database is migrated?\n" + 
          "Error: #{e.message}"
        )
      end
    end
  end # class << self
end # Zen

# Load all classes/modules provided by Zen itself.
require __DIR__('zen/validation')
require __DIR__('zen/plugin')
require __DIR__('zen/language')
require __DIR__('zen/asset')

# Load a set of modules into the global namespace
include Zen::Plugin::SingletonMethods
include Zen::Language::SingletonMethods

# Update the language path
Zen::Language.options.paths.push(__DIR__('zen'))
Zen::Language.load('zen_general')

# Load all additional files
require __DIR__('zen/plugin/helper')
require __DIR__('zen/plugin/controller')
require __DIR__('zen/plugin/markup/lib/markup')

require __DIR__('zen/package')
require __DIR__('zen/theme')

# Load all the base controllers
require __DIR__('zen/controller/base_controller')
require __DIR__('zen/controller/frontend_controller')
require __DIR__('zen/controller/admin_controller')
require __DIR__('zen/controller/main_controller')
require __DIR__('zen/controller/preview')
