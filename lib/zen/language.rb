#:nodoc:
module Zen
  ##
  # Zen comes with a system that allows developers to localize labels, field
  # names, and so on.  This can be extremely useful when you're developing a
  # package and want people to be able to use it even if they don't speak
  # English. Zen comes with a fairly easy to use language system that's based on
  # a collection of YAML files. Before you can use a language pack in your
  # package you'll have to make sure that the "language" directory exists in
  # your package directory. If so your structure should look something like the
  # following:
  #
  #     .
  #     |__ lib/
  #        |
  #        |__ my-package.rb
  #        |__ my-package/
  #           |
  #           |__ language/
  #
  # Inside the language directory there should be a directory who's name matches
  # the language key it represents. For example, a directory with translations
  # for English would be called "en". Language files for Dutch would be called
  # "nl" and so on. The name of the YAML files is also important and will be
  # used as the main key when retrieving language files. For example, if the
  # file is named "hello" it's content will be available under the hello
  # "namespace" (more on this later).
  #
  # As mentioned before language files are stored as YAML files. It doesn't
  # really matter what's in them but it's generally a good idea to format them
  # as following:
  #
  #     ---
  #     titles:
  #       index: 'Overview'
  #       edit:  'Edit Something'
  #
  # Retrieving language keys is done using the lang() method. This method takes
  # a single parameter, a string that specifies which key should be retrieved.
  # If we wanted to retrieve the key "edit" from the YAML file above you'd have
  # to do the following (assuming the YAML file is named "hello"):
  #
  #     lang('hello.titles.edit')
  #
  # As you can see sub-levels are specified using a dot between the levels. A
  # key B who's parent is A could be retrieved by doing ``lang('A.B')``.
  #
  # <div class="note todo">
  #     <p>
  #         <strong>Note</strong>: The lang() method is injected into the global
  #         namespace, you don't have to include a module in order to be able to
  #         use the method.
  #     </p>
  # </div>
  #
  # ## Loading Language Files
  #
  # In order to load a language file you'll need to do two things: add the
  # language directory to the available paths if this hasn't been done yet and
  # actually loading the file. The first can be done as following:
  #
  #     Zen::Language.options.paths.push('path/to/directory')
  #
  # This instructs the language system to look in the directory
  # ``path/to/directory`` for a directory named "language" containing all the
  # language files. Once this has been done you can load a language file using
  # ``Zen::Language.load``. The parameter of this method is the name of the YAML
  # file to load for the current language. Say there was a file
  # ``path/to/directory/language/en/test.yml``
  #
  # ## Example
  #
  # Let's assume we have a file located at
  # ``/home/yorickpeterse/foobar/language/en/foobar.yml`` with the following
  # content:
  #
  #     ---
  #     username: 'Username'
  #     location:
  #       street:  'Street'
  #       country: 'Country'
  #
  # We can load these keys as following:
  #
  #     Zen::Language.options.paths.push('/home/yorickpeterse/foobar/')
  #     Zen::Language.load('foobar')
  #
  #     lang('foobar.username')         # => "Username"
  #     lang('foobar.location.street')  # => "Street"
  #     lang('foobar.location.country') # => "Country"
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

    class << self
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
      def load(lang_name)
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
              translation = to_dotted_hash({lang_name => translation})

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
      def current
        if !Ramaze::Current.actions.nil? and !Ramaze::Current.action.nil?
          # The backend
          if Ramaze::Current.action.node.request.env['SCRIPT_NAME'] \
          =~ /^\/admin.*/
            method = :language
          # Probably the frontend
          else
            method = :frontend_language
          end

          # Extract the language from the current User object.
          if Ramaze::Helper.const_defined?(:UserHelper)
            model = Ramaze::Current.action.node.request \
              .env[::Ramaze::Helper::UserHelper::RAMAZE_HELPER_USER]

            if model.respond_to?(method)
              lang = model.send(method)
            end
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
      def to_dotted_hash(source, target = {}, namespace = nil)
        if namespace and !namespace.nil?
          prefix = "#{namespace}."
        else
          prefix = nil
        end

        if source.class == Hash
          source.each do |k, v|
            to_dotted_hash(v, target, "#{prefix}#{k}")
          end
        elsif source.class == Array
          source.each_with_index do |v, i|
            to_dotted_hash(v, target, "#{prefix}#{i}")
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
    end # class << self

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
