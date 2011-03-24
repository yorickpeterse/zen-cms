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
  require 'sequel'
  require 'ramaze'
  require 'bcrypt'
  require 'liquid'
  require 'json'
  require 'defensio'
  require 'sequel_sluggable'
  require 'yaml'
  require __DIR__('zen/version')
  
  include Innate::Optioned

  class << self
    attr_reader :languages
  end
  
  # Update several paths so we can load helpers/layouts from the Zen gem
  Innate::HelpersHelper.options.paths.push(__DIR__('zen'))
  Ramaze.options.roots.push(__DIR__('zen'))
  
  options.dsl do
    o 'The character encoding to use when dealing with data', :encoding,     'utf8'
    o 'The date format to use for log files and such.',       :date_format,  '%d-%m-%Y'
    o 'The base directory of Zen.',                           :root,         ''
  end
  
  # Load all classes/modules provided by Zen itself.
  require __DIR__ 'zen/strict_struct'
  require __DIR__ 'zen/logger'
  require __DIR__ 'zen/database'
  require __DIR__ 'zen/package'
  require __DIR__ 'zen/language'
  require __DIR__ 'zen/plugin'
  require __DIR__ 'zen/theme'

  # Load all required plugins
  require __DIR__ 'zen/plugin/markup'
  
  # Load all the base controllers
  require __DIR__ 'zen/controller/base_controller'
  require __DIR__ 'zen/controller/frontend_controller'
  require __DIR__ 'zen/controller/admin_controller'
  require __DIR__ 'zen/controller/main_controller'
  
  # Load all default Liquid tags
  require __DIR__ 'zen/liquid/general'
  require __DIR__ 'zen/liquid/controller_behavior'
  require __DIR__ 'zen/liquid/redirect'
  require __DIR__ 'zen/liquid/strip'
  
  # Update the language paths
  Zen::Language.options.paths.push(__DIR__('zen'))
  
  # Register our Liquid tags
  ::Liquid::Template.register_tag('strip'   , Liquid::Strip)
  ::Liquid::Template.register_tag('redirect', Liquid::Redirect)

  ##
  # Intitializes Zen by connecting the database and setting up various other things.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  def self.init
    # Initialize the database
    Zen::Database.init
    Zen::Language.load('zen_general')
    
    require __DIR__ 'zen/model/settings'
    require __DIR__ 'zen/model/methods'
    
    @languages = {
      'en' => lang('zen_general.special.language_hash.en')
    }
  end
end
