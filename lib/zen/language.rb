require 'zen/language/translation'

module Zen
  ##
  # ``Zen::Language`` is the heart of the multi language system that comes with
  # Zen. It makes it easy to display localized bits of text as well as adding
  # new collections of translated strings.
  #
  # ## Adding Languages
  #
  # Adding a new language can be done by using {Zen::Language.add}. This method
  # works similar to the ones used by {Zen::Package} and {Zen::Theme}. An
  # example of adding a language (English in this case) looks like the
  # following:
  #
  #     Zen::Language.add do |lang|
  #       lang.name  = 'en'
  #       lang.title = 'English'
  #     end
  #
  # When adding a language you **must** set the following items:
  #
  # <table class="table full">
  #     <thead>
  #         <tr>
  #             <th>Attribute</th>
  #             <th>Description</th>
  #         </tr>
  #     </thead>
  #     <tbody>
  #         <tr>
  #             <td>name</td>
  #             <td>
  #                 The language code as defined in
  #                 <a href="https://en.wikipedia.org/wiki/ISO_639">ISO 369</a>.
  #                 Examples of these codes are "en-GB", "nl", etc.
  #             </td>
  #         </tr>
  #         <tr>
  #             <td>title</td>
  #             <td>
  #                 A human friendly version of the name of the language. This
  #                 name should be set in the specific language. For example,
  #                 for Dutch the title should be "Nederlands" instead of
  #                 "Dutch".
  #             </td>
  #         </tr>
  #     </tbody>
  # </table>
  #
  # Optionally you can also set the following attributes:
  #
  # <table class="table full">
  #     <thead>
  #         <tr>
  #             <th>Attribute</th>
  #             <th>Description</th>
  #         </tr>
  #     </thead>
  #     <tbody>
  #         <tr>
  #             <td>rtl</td>
  #             <td>
  #                 indicates that the language reads from right to left. When
  #                 set to true the html tag will have an extra "dir" attribute
  #                 so that browsers can properly display the text from right to
  #                 left.
  #             </td>
  #         </tr>
  #     </tbody>
  # </table>
  #
  # ## Adding Translations
  #
  # Translations for a certain language are added using
  # {Zen::Language::Translation}. Similar to languages these are added by
  # calling ``.add()``. A simple example of adding a set of translations is the
  # following:
  #
  #     Zen::Language::Translation.add do |trans|
  #       trans.language = 'en'
  #       trans.name     = 'foobar'
  #
  #       trans.translate do |t|
  #
  #       end
  #     end
  #
  # This adds a language collection called "foobar" for the English language.
  # Translation strings are added inside the block of the ``translate()``
  # method. Setting these strings works just like setting the keys and values of
  # a hash:
  #
  #     trans.translate do |t|
  #       t['hello'] = 'Hello World'
  #     end
  #
  # It is a good idea to group certain language strings together. For example,
  # you might have a few strings related to page titles. The way of doing this
  # is by simply separating groups with a dot in the keys:
  #
  #     trans.translate do |t|
  #       t['titles.index'] = 'Example'
  #       t['titles.edit']  = 'Edit Example'
  #     end
  #
  # The keys specified in ``[]=`` should match the regular expression as defined
  # in {Zen::Language::Translation::KEY_REGEX}. In plain English, they can only
  # contain lower case letters, underscores and dots.
  #
  # A full example:
  #
  #     Zen::Language::Translation.add do |trans|
  #       trans.language = 'en'
  #       trans.name     = 'foobar'
  #
  #       trans.translate do |t|
  #         t['titles.index'] = 'Example'
  #         t['titles.edit']  = 'Edit Example'
  #       end
  #     end
  #
  # ## Organizing Languages
  #
  # In order for language files to be loaded by Zen you need to place them in
  # certain directories using a certain file name. Language files should be
  # named after the ``name`` setter/getter defined when calling
  # {Zen::Language::Translation.add} (including casing) and should have ``.rb``
  # as extension. These files should be placed in sub directories that match the
  # language name they belong to. These directories in turn should be placed
  # inside a "language" directory.
  #
  # In other words, our "foobar" example would be stored as following:
  #
  #      language/
  #      |
  #      |__ en/
  #         |
  #         |__ foobar.rb
  #
  # Before you can load files from the language directory you'll need to add it
  # to the list of directories to search each time a language file is loaded.
  # Similar to how you can add view folders or helper folders in Ramaze you can
  # add language folders:
  #
  #     Zen::Language.options.paths << 'path/to/language'
  #
  # ## Loading Translations
  #
  # Once a language file has been added it must be loaded before it can be used.
  # Loading a language file can be done in two ways:
  #
  # 1. Manually loading it by calling {Zen::Language.load}.
  # 2. Calling {Zen::Language.lang} or ``lang()`` (injected into the global
  #    namespace).
  #
  # In the last case missing language files will be loaded if possible. However,
  # it is recommended that you load your language files before starting the
  # application. By doing this these translations don't have to be loaded during
  # an HTTP request which could potentially slow down the application.
  #
  # If we wanted to load the "foobar" language file mentioned earlier you can do
  # this as following:
  #
  #     Zen::Language.load('foobar')
  #
  # Due to the way the language system works it's impossible to load these
  # before {Zen.start} is called. The recommended way of loading a language file
  # is by wrapping it in an event listener for the "post_start" event:
  #
  #     Zen::Event.listen :post_start do
  #       Zen::Language.load('example')
  #     end
  #
  # The reason for this requirement is that language files are stored in a cache
  # (Ramaze::Cache::LRU by default) and this cache isn't set up until
  # {Zen.start} is called.
  #
  # <div class="note todo">
  #     <p>
  #         <strong>Note:</strong>
  #         This can't be stressed enough: always load language files using the
  #         post_start event.
  #     </p>
  # </div>
  #
  # ## Using Translations
  #
  # Once the entire process of adding and loading a language file has been
  # completed you can use the language strings defined in that file. This can be
  # done by calling the global method ``lang()`` which is available in all
  # scopes. If you happen to need it in a scope where it's overwritten you can
  # call {Zen::Language.lang} instead.
  #
  # A simple example of loading a few language strings of the file defined
  # earlier in this guide looks like this:
  #
  #     lang('foobar.titles.index')
  #
  # Language keys should **always** be in the format of ``A.B`` where A is the
  # name of the language file ("foobar" in this case) and B a dot separated
  # string that points to the language string to load. This means that the
  # following examples are not valid:
  #
  #     lang('foobar')
  #     lang('foo bar')
  #
  # <div class="note todo">
  #     <p>
  #         <strong>Note:</strong>
  #         Because language files aren't loaded until Zen.start is called you
  #         should never use or rely on translations before the application has
  #         started. Most of the core code works around this by loading
  #         translations using blocks whenever they're needed.
  #     </p>
  # </div>
  #
  # [iso 639]: https://en.wikipedia.org/wiki/ISO_639
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

    # A hash of all the language files that have been loaded for a language. The
    # values are the names of these collections and the values the instances of
    # {Zen::Language::Translation}.
    attr_accessor :collections

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
      # Loads the given language file for the currently used language. If the
      # file has already been loaded this method will not load it again.
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

        return if language.collections.keys.include?(lang_name)

        options.paths.each do |path|
          path = File.join(path, language.name, "#{lang_name}.rb")

          # Load the language
          if File.exist?(path)
            require(path)

            unless language.collections[lang_name].nil?
              language.collections[lang_name].load
              return
            end
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
      # Returns a string containing the text direction if the current language
      # is an rtl language.
      #
      # @since  14-11-2011
      # @return [String]
      #
      def html_text_direction
        if Zen::Language.current.rtl == true
          return 'dir="rtl"'
        end
      end
    end # class << self

    ##
    # Creates a new instance of the class.
    #
    # @since 14-11-2011
    #
    def initialize
      @loaded      = []
      @collections = {}
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
      # Retrieves a single language string.
      #
      # @example
      #  lang('users.titles.index')
      #
      # @since  0.2
      # @param  [String] key The language key to retrieve.
      # @param  [String] lang The language for which to retrieve the key,
      #  overwrites the language set in the session.
      # @return [Mixed]
      #
      def lang(key, lang = nil)
        unless key =~ Zen::Language::Translation::KEY_REGEX
          raise(
            Zen::LanguageError,
            "The format of the language key \"#{key}\" is invalid"
          )
        end

        lang   = Zen::Language.current.name if lang.nil?
        key    = key.to_s  unless key.is_a?(String)
        lang   = lang.to_s unless lang.is_a?(String)

        unless Zen::Language::REGISTERED.key?(lang)
          raise(Zen::LanguageError, "The language \"#{lang}\" doesn't exist")
        end

        group     = key.split('.')[0]
        cache_key = [lang, key].join('.')
        got       = Ramaze::Cache.translations.fetch(cache_key)

        return got unless got.nil?

        # It seems the language item couldn't be fetched. This can happen when
        # the user change the language but hasn't loaded a specific language set
        # yet. Lets load it and try again.
        Zen::Language.load(group, lang)

        got = Ramaze::Cache.translations.fetch(cache_key)

        return got unless got.nil?

        # Last step: check if the cache has been cleared. If this is the case
        # the language pack should be reloaded, otherwise an error will be
        # raised.
        REGISTERED[lang].collections[group].load

        got = Ramaze::Cache.translations.fetch(cache_key)

        unless got.nil?
          Ramaze::Log.warn(
            "The language item \"#{key}\" has been added to the cache as it " \
              'appeared to be missing'
          )

          return got
        end

        raise(
          Zen::LanguageError,
          "The specified language item \"#{key}\" does not exist"
        )
      end
    end # SingletonMethods
  end # Language
end # Zen
