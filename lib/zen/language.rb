require 'zen/language/translation'

module Zen
  ##
  #
  # @since  0.2
  #
  class Language
    include Zen::Validation
    include Ramaze::Optioned

    # Hash containing all the available languages.
    REGISTERED = {}

    options.dsl do
      o 'Fallback language to use when it can not be retrieved from the user',
        :language, 'en'

      o 'Array of paths to look for the language files',
        :paths, []
    end

    # The name of the language
    attr_reader :name

    # Whether or not the language reads from right to left.
    attr_writer :rtl

    # The title of the language (in that specific language).
    attr_accessor :title

    # Array containing all the loaded language files.
    attr_accessor :loaded

    class << self
      ##
      # Adds a new language.
      #
      # @example
      #  Zen::Language.add do |lang|
      #    lang.name  = 'nl'
      #    lang.title = 'Nederlands'
      #  end
      #
      # @example Adding an RTL language (such as Japanese)
      #  Zen::Language.add do |lang|
      #    lang.name  = '...'
      #    lang.title = '...'
      #    lang.rtl   = true
      #  end
      #
      # @since 14-11-2011
      # @yield Zen::Language
      #
      def add
        lang = new

        yield(lang)

        lang.validate

        REGISTERED[lang.name] = lang
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
      # @since  0.1
      # @param  [String] lang_name The name of the language file to load.
      # @param  [String] lang The name of the language for which to load the
      #  collection. Set to the current language by default.
      #
      def load(lang_name, lang = nil)
        lang_name = lang_name.to_s unless lang_name.is_a?(String)
        language  = REGISTERED[lang.to_s] || current

        return if language.loaded.include?(lang_name)

        options.paths.each do |path|
          path = File.join(path, language.name, "#{lang_name}.rb")

          # Load the language
          if File.exist?(path)
            require(path)
            language.loaded.push(lang_name)

            return
          end
        end

        raise(
          Zen::LanguageError,
          "No language file could be found for \"#{lang_name}\""
        )
      end

      ##
      # Returns an instance of {Zen::Language} for the current language.
      #
      # @since  0.3
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
              lang = get_setting(method).value
            else
              lang = get_setting(:language).value
            end
          rescue
            lang = Zen::Language.options.language
          end
        end

        return REGISTERED[lang]
      end

      ##
      # Returns a hash where the keys are the language codes and the values the
      # titles.
      #
      # @since  14-11-2011
      # @return [Hash]
      #
      def to_hash
        hash = {}

        REGISTERED.each { |lang, obj| hash[lang] = obj.title }

        return hash
      end

      ##
      # Builds an HTML opening tag with the lang and rtl attributes set for the
      # currently used language.
      #
      # @since  14-11-2011
      # @return [String]
      #
      def html_head
        curr = Zen::Language.current
        head = "<html lang=\"#{curr.name}\""

        if curr.rtl == true
          header += ' dir="rtl"'
        end

        return head + '>'
      end
    end # class << self

    ##
    # Creates a new instance of the class.
    #
    # @since 14-11-2011
    #
    def initialize
      @loaded = []
    end

    ##
    # Sets the name of the language and converts it to a string.
    #
    # @since 14-11-2011
    # @param [#to_s] name The name of the language.
    #
    def name=(name)
      @name = name.is_a?(String) ? name : name.to_s
    end

    ##
    # Returns a boolean that indicates whether or not the language reads from
    # right to left.
    #
    # @since  14-11-2011
    # @return [TrueClass|FalseClass]
    #
    def rtl
      return @rtl.nil? ? false : @rtl
    end

    ##
    # Validates the current instance using {Zen::Validation}.
    #
    # @since 14-11-2011
    #
    def validate
      validates_presence([:name, :title])

      if REGISTERED.key?(name)
        raise(Zen::ValidationError, "The language #{name} already exists.")
      end
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
      # @since  0.2
      # @param  [String] key The language key to select.
      # @param  [String] lang The language for which to retrieve the key,
      #  overwrites the language set in the session.
      # @return [Mixed]
      #
      def lang(key, lang = nil)
        lang   = Zen::Language.current.name if lang.nil?
        key    = key.to_s  unless key.is_a?(String)
        lang   = lang.to_s unless lang.is_a?(String)

        unless Zen::Language::REGISTERED.key?(lang)
          raise(Zen::LanguageError, "The language \"#{lang}\" doesn't exist")
        end

        group = key.split('.')[0]
        got   = Ramaze::Cache.translations.fetch([lang, key].join('.'))

        if !got.nil?
          return got
        end

        # It seems the language item couldn't be fetched. This can happen when
        # the user change the language but hasn't loaded a specific language set
        # yet. Lets load it and try again.
        Zen::Language.load(group, lang)

        got = Ramaze::Cache.translations.fetch([lang, key].join('.'))

        return got unless got.nil?

        raise(
          Zen::LanguageError,
          "The specified language item \"#{key}\" does not exist"
        )
      end
    end # SingletonMethods
  end # Language
end # Zen
