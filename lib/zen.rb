require 'sequel'
require 'ramaze'
require 'bcrypt'
require 'json'
require 'defensio'
require 'sequel_sluggable'
require 'yaml'
require __DIR__('zen/version')

##
# Main module for Zen, all other modules and classes will be placed inside this module.
# This module loads all required classes and is used for starting the application.
#
# @author Yorick Peterse
# @since  0.1
# @attr_reader [Array] languages An array containing all the currently loaded language
# files stored as hashes.
#
module Zen
  include Innate::Optioned
  
  # Update several paths so we can load helpers/layouts from the Zen gem
  Innate::HelpersHelper.options.paths.push(__DIR__('zen'))
  Ramaze.options.roots.push(__DIR__('zen'))
  
  options.dsl do
    o 'The character encoding to use when dealing with data', :encoding,     'utf8'
    o 'The date format to use for log files and such.',       :date_format,  '%d-%m-%Y'
    o 'The root directory of Zen.',                           :root,         ''
  end

  ##
  # Hash containing all system settings.
  #
  # @author Yorick Peterse
  # @since  0.2.5
  #
  Settings = {}

  ##
  # Loads the database and the required models.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  def self.init
    # Initialize the database
    Zen::Database.init
    Zen::Language.load('zen_general')
    
    require __DIR__('zen/model/settings')
    require __DIR__('zen/model/methods')
  end

end

# Load all classes/modules provided by Zen itself.
require __DIR__('zen/validation')
require __DIR__('zen/database')
require __DIR__('zen/plugin')
require __DIR__('zen/language')
require __DIR__('zen/logger')
require __DIR__('zen/asset')

# Load a set of modules into the global namespace 
include Zen::Plugin::SingletonMethods
include Zen::Language::SingletonMethods

# Update the language path
Zen::Language.options.paths.push(__DIR__('zen'))

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
