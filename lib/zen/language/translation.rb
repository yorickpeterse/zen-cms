module Zen
  class Language
    ##
    # Class used to specify all the translations in a language file/pack. In
    # order to add a translation you need to specify the language, the name of
    # the collection and a bunch of strings to translate. This is done as
    # following:
    #
    #     Zen::Language::Translation.add do |t|
    #       t.language = 'en'
    #       t.name     = 'users'
    #
    #       t['titles.index'] = 'Users'
    #     end
    #
    # Translations are added by calling ``#[]=`` on the block parameter (``t``
    # in the above example).
    #
    # For more general and expanded information see {Zen::Language}.
    #
    # @since 16-11-2011
    #
    class Translation
      # The name of the language this set of translations belongs to.
      attr_reader :language

      # The name of the set of translations.
      attr_reader :name

      ##
      # Adds a new translation set.
      #
      # @example
      #  Zen::Language::Translation.add do |t|
      #    t.language = 'en'
      #    t.name     = 'users'
      #  end
      #
      # @since 16-11-2011
      # @yield Zen::Language::Translation
      #
      def self.add
        trans = new

        yield(trans)
      end

      ##
      # Sets the language for the collection of translations.
      #
      # @since 16-11-2011
      # @param [#to_s] language The language code.
      # @raise Zen::ValidationError Raised whenever a given language is invalid.
      #
      def language=(language)
        unless Zen::Language::REGISTERED.key?(language)
          raise(
            Zen::ValidationError,
            "The language \"#{language}\" doesn't exist"
          )
        end

        @language = language.is_a?(String) ? language : language.to_s
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
        Ramaze::Cache.translations.store([language, name, key].join('.'), value)
      end
    end # Translation
  end # Language
end # Zen
