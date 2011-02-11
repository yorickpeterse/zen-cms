require 'ostruct'

module Zen
  ##
  # The Language module enables developers to create multi-lingual applications/extensions using
  # nothing more than Ruby. While Ramaze already ships with multi-language support it relies on YAML
  # for it's language files. While YAML is nice for config/language files my aim is to keep everything in Ruby
  # as much as possible. Another problem with the language class provided by Ramaze is that at the time of writing
  # (October 2011) it was completely undocumented and didn't make much sense.
  #
  # h2. Usage
  #
  # Using the language system provided by Zen is fairly straight forward. Create a directory named "language"
  # and create a sub directory for each language. For example, if you're adding an English language pack this directory would be named "en".
  # Language files can be named whatever you like as long as they contain the following block:
  #
  # bc. Zen::Language.translation 'translation_name' do |item|
  #   # ...
  # end
  #
  # Inside this block you'll define your language items. For example, if we want a localized username and password we could
  # do something like the following:
  #
  # bc. Zen::Language.translation 'example' do |item|
  #   item.username = 'Username'
  #   item.passowrd = 'Password'
  # end
  #
  # This language file can then be loaded as following (assuming it's named "example.rb"):
  # 
  # bc. lang = Zen::Language.load 'example'
  # # We can now access our translation items from the lang variable
  # lang.username
  # lang.password
  #
  # Zen will use the setting Zen.options.language to determine what language should be loaded.
  #
  # h2. Sub Items
  #
  # Since language files are nothing more than Ruby blocks you can do everything you normally can. This makes
  # it extremely easy to retrieve dynamic data for your language files (a list of installed extensions for example).
  # Sub items are generally specified as a hash:
  #
  # bc. item.sub_items = {:name => 'Name'}
  #
  # Note that Zen won't convert the keys from format A to B, if you specify a symbol it will stay a symbol.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  module Language
    @language_keys  = {}
    @language_paths = []
    
    class << self
      attr_accessor :language_keys
      attr_accessor :language_paths
    end
    
    ##
    # Tries to load the specified language file from each directory specified in Ramaze.options.roots.
    # After a language file has been loaded the OpenStruct object will be stored in a hash and returned
    # in case the same language file is loaded multiple times.
    # 
    # @example
    #  @user_lang = Zen::Language.load 'user'
    #  @user_lang.username
    #
    # @author Yorick Peterse
    # @param  [String] lang_name The name of the language file to load. This name should match both
    # the filename and the name defined in Zen::Language.translation().
    # @return [Object] An OpenStruct object containing all the language keys and their values.
    # 
    def self.load lang_name
      # Each language file is stored in the hash using a key with the following format:
      # language-name_language-file
      hash_key = Zen.options.language + '_' + lang_name
      hash_key = hash_key.to_sym

      # Let's see if the language file is already loaded
      if @language_keys.key?(hash_key)
        return @language_keys[hash_key]
      end
      
      # Time to load the file
      paths = @language_paths + Ramaze.options.roots
      
      paths.each do |dir|
        lang_path = "#{dir}/language/#{Zen.options.language}/#{lang_name}.rb"

        # Load the file if it exists
        if File.exist?(lang_path)
          require lang_path  
          return @language_keys[hash_key]
        end
      end
      
      # No language file found
      return false
    end
    
    ##
    # Given a block this method will store all the keys in the language_keys instance variable.
    # Using Zen::Language.load these variables will be returned as an OpenStruct object.
    #
    # @example
    #  Zen::Language.translation 'example' do |lang|
    #    lang.username = 'Username'
    #    lang.password = 'Password'
    #  end
    #
    # @author Yorick Peterse
    # @param  [Block] Block containing all the language items.
    #
    def self.translation lang_name, &block
      # Each language file is stored in the hash using a key with the following format:
      # language-name_language-file
      hash_key = Zen.options.language + '_' + lang_name
      hash_key = hash_key.to_sym
      
      # Does the language key already exist?
      if @language_keys.key?(hash_key)
        raise "There already is a language file named \"#{lang_name}\" for the language \"#{Zen.options.language}\"."
      end
      
      # Process the language file
      @language_keys[hash_key] = OpenStruct.new
      
      yield @language_keys[hash_key]
    end
  end
end