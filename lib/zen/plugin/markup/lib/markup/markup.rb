#:nodoc
module Zen
  #:nodoc
  module Plugin
    ##
    # The Markup plugin is used to convert the given markup using the specified
    # engine.  Out of the box this plugin is capable of doing the following:
    #
    # * Markdown -> HTML
    # * Textile -> HTML
    # * HTML -> Plain text (escapes HTML)
    # * Regular HTML
    #
    # When using Markdown you'll have to make sure RDiscount is loaded, for
    # Textile this should be RedCloth.
    #
    # ## Usage
    #
    # Using this plugin can be done as following::
    #
    #     plugin(:markup, :markdown, "hello **world**")
    #
    # ## Adding Engines
    #
    # In order to add a custom markdown engine (e.g. RDoc) you'll have to update
    # Zen::Plugin::Markup::Engines so that it includes the name and human
    # readable name of the engine you wish to use. This can be done as
    # following:
    #
    #     Zen::Plugin::Markup::Engines[:rdoc] => 'RDoc'
    #
    # Once this is done you'll need to define a method that matches the key
    # you've just added. In this case it will be named "rdoc":
    #
    #     module Zen
    #       module Plugin
    #         class Markup
    #           def rdoc(markup)
    #             # Do something with the markup in the variable "markup"
    #           end
    #         end
    #       end
    #     end
    #
    # Once this has been done you're able to convert RDoc markup to HTML using
    # this plugin.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Markup
      include Ramaze::Helper::CGI

      ##
      # Hash containing the keys of the engines to use and their human friendly
      # names (used in the backend). Note that the keys of this hash should be
      # strings.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      Engines = {
        'markdown' => Zen::Language.lang('markup.engines.markdown'),
        'textile'  => Zen::Language.lang('markup.engines.textile'),
        'plain'    => Zen::Language.lang('markup.engines.plain'),
        'html'     => Zen::Language.lang('markup.engines.html')
      }

      ##
      # Creates a new instance of the markup plugin and validates all the given
      # parameters.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Symbol] engine The markup engine to use (e.g. :markdown).
      # @param  [String] markup The markup to convert to HTML or something else.
      #
      def initialize(engine = 'markdown', markup = '')
        @engine, @markup = engine.to_s, markup

        # Validate the given engine
        if !Engines.keys.include?(@engine)
          raise(
            ArgumentError,
            "The markup engine \"#{@engine}\" is invalid."
          )
        end

        # Does the engine have a matching method?
        if !respond_to?(@engine)
          raise(
            NoMethodError,
            "The engine \"#{@engine}\" has no matching method."
          )
        end
      end

      ##
      # Converts the markup into HTML or plain text.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [String] The converted markup.
      #
      def call
        return send(@engine, @markup)
      end

      ##
      # Converts the Markdown markup to HTML using RDiscount.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The Markdown string to convert to HTML.
      # @return [String] The HTML returned by RDiscount.
      #
      def markdown(markup)
        return RDiscount.new(markup).to_html
      end

      ##
      # Converts Textile to HTML using RedCloth.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The Textile markup to convert to HTML.
      # @return [String] The HTML returned by RedCloth.
      #
      def textile(markup)
        return RedCloth.new(markup).to_html
      end

      ##
      # Escapes all HTML using Ramaze::Helper::CGI.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The markup in which all HTML tags should be
      #  escaped.
      # @return [String] String containing the escaped HTML.
      #
      def plain(markup)
        return h(markup)
      end

      ##
      # Ignores the markup and just returns it.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The markup to return.
      # @return [String] String containing our markup.
      #
      def html(markup)
        return markup
      end
    end # Markup
  end # Plugin
end # Zen
