#:nodoc:
module Zen
  ##
  # The language module is used for writing and using text translations.
  # Translations are stored in a simple YAML file inside a directory called
  # "language" followed by a directory who's name matches the language code for
  # which it's translations should be used. Say we wanted to translate "Login"
  # and "Register" into different languages our YAML file would look like the
  # following:
  #
  #     ---
  #     login: "Login"
  #     register: "Register"
  #
  # If we save this file under parent_directory/language/en/tutorial.yml we
  # could then load that file as following:
  #
  #     Zen::Language.load('tutorial')
  #
  # ## Loading Translations
  #
  # The load() method will look for a YAML file of which the name matches the
  # given string and can be found in the directory for the current language.
  # This means that if we were to switch our language without creating a
  # translation file for that language we wouldn't be able to use it
  # (makes sense right?).
  #
  # Once your translation file is in place and it's loaded it can be used using
  # the lang() method. Example:
  #
  #     lang('tutorial.login') # => "Login"
  #
  # ## Directory Structure
  #
  # As mentioned earlier language files are saved in a certain directory. The
  # structure of this directory looks like the following:
  #
  #     parent directory
  #       |
  #       |__ language
  #          |
  #          |__ language key (e.g. "en")
  #             |
  #             |__ filename.yml
  #
  # When loading a language file this module will loop through a certain number
  # of paths. The array containing all base directories to loop through can be
  # updated as following:
  #
  #     Zen::Language.options.paths.push('/path/to/directory')
  #
  # It's important that you _don't_ add a /language segment to the path, this
  # will be done automatically.
  #
  # ## Options
  #
  # * language: Small string that defines the current language (e.g. "en").
  # * paths: Array of paths to look for a language directory. Note that this
  #   should be the parent directory of the directory called "language", not the
  #   actual directory itself.
  #
  # @author Yorick Peterse
  # @since  0.2
  #
  module Language
    include Ramaze::Optioned

    # Hash containing all the translations.
    Translations = {}

    # Hash containing all the loaded language files for a language.
    Loaded = {}

    # Hash containing all the available languages.
    Languages = {
      'en' => 'English',
      'nl' => 'Nederlands'
    }

    options.dsl do
      o 'Fallback language to use when it can not be retrieved from the user',
        :language, 'en'

      o 'Array of paths to look for the language files',
        :paths, []
    end

    ##
    # Tries to load a language file for the given name. If no language files
    # were found based on the name and the current language an exception will
    # be raised.
    #
    # Note that this method will load the language pack for *all* languages.
    #
    # @example
    #  Zen::Language.load('user')
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] lang_name The name of the language file to load.
    #
    def self.load(lang_name)
      lang_name  = lang_name.to_s
      file_found = false

      Languages.each do |language, label|
        Loaded[language]       ||= []
        Translations[language] ||= {}

        # Abort of the file has already been loaded
        if Loaded.key?(language) and Loaded[language].include?(lang_name)
          file_found = true
          break
        end

        self.options.paths.each do |path|
          path += "/language/#{language}/#{lang_name}.yml"

          # Load the file and save it
          if File.exist?(path)
            file_found  = true
            translation = YAML.load_file(path)

            Loaded[language].push(lang_name)

            # Conver the hash to a dot based hash. This means that
            # {:person => {:age => 18}} would result in {'person.age' => 18}.
            translation = self.to_dotted_hash({lang_name => translation})

            Translations[language].merge!(translation)
          end
        end
      end

      if file_found === false
        raise(
          Zen::LanguageError,
          "No language file could be found for \"#{lang_name}\""
        )
      end
    end

    ##
    # Returns the language code to use for either the frontend or backend.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @return [String]
    #
    def self.current
      if !Ramaze::Current.actions.nil? and !Ramaze::Current.action.nil?
        # The backend
        if Ramaze::Current.action.node.request.env['SCRIPT_NAME'] \
        =~ /^\/admin.*/
          method = :language
        # Probably the frontend
        else
          method = :frontend_language
        end

        if Ramaze::Current.action.node.session[:user].respond_to?(method)
          lang = Ramaze::Current.action.node.session[:user].send(method)
        end
      end

      # Make sure there always is a language set
      if !lang
        # Plugins aren't available yet when this class is loaded, use the
        # fallback language if needed.
        begin
          if method
            lang = plugin(:settings, :get, method).value
          else
            lang = plugin(:settings, :get, :language).value
          end
        rescue
          lang = Zen::Language.options.language
        end
      end

      return lang
    end

    private

    ##
    # Method that takes a hash or an array and converts it to a dot-based hash.
    # For example, the following hash:
    #
    #     {
    #       :name     => 'Name',
    #       :location => {
    #         :street  => 'Street',
    #         :address => 'Address'
    #       }
    #     }
    #
    # would result in the following:
    #
    #     {
    #       'name'             => 'Name',
    #       'location.street'  => 'Street',
    #       'location.address' => 'Address'
    #     }
    #
    # Using arrays would result in the following:
    #
    #     out = to_dotted_hash(["Hello", "World"])
    #     puts out # => {'1' => 'Hello', '2' => 'World'}
    #
    # While it looks a bit goofy this allows you to do the following:
    #
    #     lang('1') # => 'Hello'
    #
    # @example
    #  self.to_dotted_hash({:name => "Yorick"}) # => {'name' => 'Yorick'}
    #
    # The code for this method was mostly taken from a comment on Stack
    # Overflow. This comment can be found here: <http://bit.ly/dHTjVR>
    #
    # @author Yorick Peterse
    # @since  0.2
    # @param  [Hash/Array] source The hash or array to conver to a dot-based
    #  hash.
    # @param  [Hash] target The hash to store the new key/values in.
    # @param  [String] namespace The namespace for the key
    #  (e.g. "user.location").
    # @return [Hash] The converted hash where the keys are dot-based strings
    #  instead of regular strings/symbols with sub hashes.
    #
    def self.to_dotted_hash(source, target = {}, namespace = nil)
      if namespace and !namespace.nil?
        prefix = "#{namespace}."
      else
        prefix = nil
      end

      if source.class == Hash
        source.each do |k, v|
          self.to_dotted_hash(v, target, "#{prefix}#{k}")
        end
      elsif source.class == Array
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

    #:nodoc:
    module SingletonMethods
      ##
      # Method for retrieving the correct language item based on the given
      # string. If you want to retrieve sub-items you can separate each level
      # with a dot:
      #
      #     lang('tutorial.main.sub')
      #
      # This would require our YAML file to look something like the following:
      #
      #     ---
      #     main:
      #       sub: "Something!"
      #
      # It's important to remember that your key should always include the name
      # of the language file since once a file is loaded it will be kept in
      # memory to reduce disk usage.
      #
      # @example
      #  lang('username')
      #
      # @author Yorick Peterse
      # @since  0.2
      # @param  [String] key The language key to select.
      # @param  [String] lang The language for which to retrieve the key,
      #  overwrites the language set in the session.
      # @return [Mixed]
      #
      def lang(key, lang = nil)
        lang   = Zen::Language.current if lang.nil?
        groups = []

        if !Zen::Language::Translations \
        or !Zen::Language::Translations.key?(lang)
          raise(
            Zen::LanguageError,
            "No translation files have been added for the language code \"#{lang}\""
          )
        end

        if Zen::Language::Translations[lang][key]
          return Zen::Language::Translations[lang][key]
        end

        raise(
          Zen::LanguageError,
          "The specified language item \"#{key}\" does not exist"
        )
      end
    end
  end # Language
end # Zen
