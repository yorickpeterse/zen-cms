require __DIR__('error/language_error')

#:nodoc:
module Zen
  ##
  # The language module is used for writing and using text translations. Translations are
  # stored in a simple YAML file inside a directory called "language" followed by a directory
  # who's name matches the language code for which it's translations should be used.
  # Say we wanted to translate "Login" and "Register" into different languages our YAML
  # file would look like the following:
  #
  #     ---
  #     login: "Login"
  #     register: "Register"
  #
  # If we save this file under parent_directory/language/en/tutorial.yml we could then
  # load that file as following:
  #
  #     Zen::Language.load('tutorial')
  #
  # ## Loading Translations
  #
  # The load() method will look for a YAML file of which the name matches the given string
  # and can be found in the directory for the current language. This means that if we were
  # to switch our language without creating a translation file for that language we wouldn't
  # be able to use it (makes sense right?).
  #
  # Once your translation file is in place and it's loaded it can be used using the lang()
  # method. Example:
  #
  #     lang('tutorial.login') # => "Login"
  #
  # ## Directory Structure
  #
  # As mentioned earlier language files are saved in a certain directory. The structure
  # of this directory looks like the following:
  #
  #     parent directory
  #       |
  #       |__ language
  #          |
  #          |__ language key (e.g. "en")
  #             |
  #             |__ filename.yml
  #
  # When loading a language file this module will loop through a certain number of paths.
  # The array containing all base directories to loop through can be updated as following:
  #
  #     Zen::Language.options.paths.push('/path/to/directory')
  #
  # It's important that you _don't_ add a /language segment to the path, this will be done
  # automatically.
  #
  # ## Options
  #
  # * language: Small string that defines the current language (e.g. "en").
  # * paths: Array of paths to look for a language directory. Note that this should be
  # the parent directory of the directory called "language", not the actual directory
  # itself.
  #
  # @author Yorick Peterse
  # @since  0.2 
  #
  module Language
    include Ramaze::Optioned

    options.dsl do
      o 'Small string that defines the current language (e.g. "en").', :language, 'en'
      o 'Array of paths to look for the language files'              , :paths   , [] 
    end

    class << self
      attr_reader :translations
    end
    
    ##
    # Tries to load a language file for the given name. If no language files were found
    # based on the name and the current language an exception will be raised. 
    #
    # @example
    #  Zen::Language.load('user')
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] lang_name The name of the language file to load. 
    # 
    def self.load(lang_name)
      @translations                             ||= {}
      @translations[self.options.language.to_s] ||= {}

      if @translations[self.options.language.to_s][lang_name.to_s]
        return
      end

      self.options.paths.each do |path|
        path += "/language/#{self.options.language}/#{lang_name}.yml"

        # Load the file and save it
        if File.exist?(path)
          translation = YAML.load_file(path)

          # Conver the hash to a dot based hash. This means that {:person => {:age => 18}}
          # would result in {'person.age' => 18}.
          translation = self.to_dotted_hash({lang_name.to_s => translation})
          
          @translations[self.options.language.to_s] ||= {}
          @translations[self.options.language.to_s].merge!(translation)
          
          # Prevents the exception from being raised
          return
        end        
      end

      raise(Zen::LanguageError, "No language file could be found for \"#{lang_name}\"")
    end

    ##
    # Method for retrieving the correct language item based on the given string.
    # If you want to retrieve sub-items you can separate each level with a dot:
    #
    #     lang('tutorial.main.sub')
    #
    # This would require our YAML file to look something like the following:
    #
    #     ---
    #     main:
    #       sub: "Something!"
    #
    # It's important to remember that your key should always include the name of the
    # language file since once a file is loaded it will be kept in memory to reduce
    # disk usage.
    #
    # @example
    #  lang('username')
    #
    # @author Yorick Peterse
    # @since  0.2
    # @param  [String] key The language key to select.
    # @return [Mixed]
    #
    def lang(key)
      lang          = ::Zen::Language.options.language.to_s
      groups        = []
      translations  = ::Zen::Language.translations

      if !translations or !translations.key?(lang)
        raise(
          Zen::LanguageError, 
          "No translation files have been added for the language code \"#{lang}\""
        )
      end

      if translations[lang][key]
        return translations[lang][key]
      end
      
      raise(
        Zen::LanguageError,
        "The specified language item \"#{key}\" does not exist"
      )
    end

    private

    ##
    # Method that takes a hash or an array and converts it to a dot-based hash. For example,
    # the following hash:
    #
    #     {:name => 'Name', :location => {:street => 'Street', :address => 'Address'}}
    #
    # would result in the following:
    #
    #     {'name' => 'Name', 'location.street' => 'Street', 'location.address' => 'Address'}
    #
    # Using arrays would result in the following:
    #
    #     to_dotted_hash(["Hello", "World"]) # => {'1' => 'Hello', '2' => 'World'}
    #
    # While it looks a bit goofy this allows you to do the following:
    #
    #     lang('1') # => 'Hello'
    #
    # @example
    #  self.to_dotted_hash({:name => "Yorick"}) # => {'name' => 'Yorick'}
    #
    # The code for this method was mostly taken from a comment on Stack Overflow.
    # This comment can be found here: <http://bit.ly/dHTjVR>
    #
    # @author Yorick Peterse
    # @since  0.2
    # @param  [Hash/Array] source The hash or array to conver to a dot-based hash.
    # @param  [Hash] target The hash to store the new key/values in.
    # @param  [String] namespace The namespace for the key (e.g. "user.location").
    # @return [Hash] The converted hash where the keys are dot-based strings instead of
    # regular strings/symbols with sub hashes.
    #
    def self.to_dotted_hash(source, target = {}, namespace = nil)
      if namespace and !namespace.nil?
        prefix = "#{namespace}."
      else
        prefix = ""
      end

      case source
      when Hash
        source.each do |k, v|
          self.to_dotted_hash(v, target, "#{prefix}#{k}")
        end
      when Array
        source.each_with_index do |v, i|
          self.to_dotted_hash(v, target, "#{prefix}#{i}") 
        end
      else
        if !namespace.nil?
          target[namespace] = source
        else
          target = source
        end
      end

      return target
    end
  end
end
