module Zen
  class Language
    ##
    # Class used to specify all the translations in a language file/pack. In
    # order to add a translation you need to specify the language, the name of
    # the collection and a bunch of strings to translate. This is done as
    # following:
    #
    #     Zen::Language::Translation.add do |trans|
    #       trans.language = 'en'
    #       trans.name     = 'users'
    #
    #       trans.translate do |t|
    #         t['titles.index'] = 'Users'
    #       end
    #     end
    #
    # For more general and expanded information see {Zen::Language}.
    #
    # @since 16-11-2011
    #
    class Translation
      include Zen::Validation

      # A regex that specifies the allowed format of language keys.
      KEY_REGEX = /^[0-9a-z_\.]+$/

      # The name of the language this set of translations belongs to.
      attr_reader :language

      # The name of the set of translations.
      attr_reader :name

      # A block containing all the translations for the language file.
      attr_accessor :translations

      ##
      # Adds a new translation set.
      #
      # @since 16-11-2011
      # @yield Zen::Language::Translation
      #
      def self.add
        trans = new

        yield(trans)

        trans.validate

        REGISTERED[trans.language].collections[trans.name] = trans
      end

      ##
      # Sets the language for the collection of translations.
      #
      # @since 16-11-2011
      # @param [#to_s] language The language code.
      # @raise Zen::ValidationError Raised whenever a given language is invalid.
      #
      def language=(language)
        @language = language.is_a?(String) ? language : language.to_s
      end

      ##
      # Stores the supplied block containing all translations in
      # ``@translations``.
      #
      # @since 17-11-2011
      # @param [Proc] block A block containing all calls to ``#[]=()``.
      #
      def translate(&block)
        @translations = block
      end

      ##
      # Loads the translations by invoking the block that was set using
      # {#translate}.
      #
      # @since 17-11-2011
      #
      def load
        @translations.call(self)
      end

      ##
      # Sets the name of the collection of translations.
      #
      # @since 16-11-2011
      # @param [#to_s] name The name of the collection.
      #
      def name=(name)
        @name = name.is_a?(String) ? name : name.to_s
      end

      ##
      # Adds a new translation by directly storing it in the cache
      # ``Ramaze::Cache.translations``.
      #
      # @since 16-11-2011
      # @param [#to_s] key The name of the language item, an example is
      #  "titles.index".
      # @param [#to_s] value The value of the language item.
      #
      def []=(key, value)
        unless key =~ KEY_REGEX
          raise(
            Zen::LanguageError,
            "The format of the language key \"#{key}\" is invalid"
          )
        end

        Ramaze::Cache.translations.store([language, name, key].join('.'), value)
      end

      ##
      # Validates the instance.
      #
      # @since 17-11-2011
      #
      def validate
        validates_presence([:name, :name, :translations])

        unless Zen::Language::REGISTERED.key?(language)
          raise(
            Zen::ValidationError,
            "The language \"#{language}\" doesn't exist"
          )
        end
      end
    end # Translation
  end # Language
end # Zen
