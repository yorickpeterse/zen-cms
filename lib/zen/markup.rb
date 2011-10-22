module Zen
  ##
  # {Zen::Markup} is a module that makes it easy to convert markup from one
  # format to another. It can be used to generate HTML using Markdown and
  # Textile or to escape HTML using ``Ramaze::Helper::CGI``.
  #
  # Using this module is quite easy, simply call the ``.convert`` method of and
  # pass the name of the markup engine you'd like to use to it along with some
  # markup. For example, to convert Markdown to HTML you'd call the following:
  #
  #     html = Zen::Markup.convert(:markdown, 'Hello **world**')
  #
  # When converting Markdown or Textile Zen will automatically install the
  # required gems. For Markdown RDiscount is used, for Textile RedCloth is used.
  #
  # You may be tempted to call the various methods directly but it is not
  # recommended to do so. For example, you might have the following code:
  #
  #     # Taken from an HTML form
  #     engine = 'markdown'
  #     markup = '...'
  #     html   = Zen::Markdown.send(engine, markup)
  #
  # This however makes it possible to do some serious damage. Consider the
  # following:
  #
  #     engine = 'instance_eval'
  #     markup = 'eval("....")'
  #     html   = Zen::Markdown.send(engine, markup)
  #
  # Because of this you should use {Zen::Markup.convert} instead as this method
  # will verify the engine name before calling the method for it.
  #
  # ## Adding Markup Engines
  #
  # Adding a new engine is relatively easy and is done in two steps. First you
  # should add the name of your engine and it's label to
  # {Zen::Markup::Registered}. The keys of this hash should be the methods to
  # call, teh values will be displayed in various ``<select>`` elements in the
  # administration interface.
  #
  #     Zen::Markup::Registered['my_markup'] = 'My Markup'
  #
  # In this example the label is hardcoded but it's recommended to use
  # {Zen::Language.lang} instead.
  #
  # Once the engine has been added to the list you'll have to add a
  # corresponding method. This can be done as following:
  #
  #     module Zen
  #       module Markup
  #         private
  #
  #         def self.my_markup(markup)
  #
  #         end
  #       end
  #     end
  #
  # Each markup method should be a class method and should take a single
  # parameter. This parameter will contain the markup to convert. The return
  # value of these methods should be the converted markup:
  #
  #     module Zen
  #       module Markup
  #         private
  #
  #         def self.my_markup(markup)
  #           return markup.upcase
  #         end
  #       end
  #     end
  #
  # @author Yorick Peterse
  # @since  0.2.5
  #
  module Markup
    # Hash containing all the markup engines and their names as they'll be
    # displayed in the backend.
    Registered = {
      'markdown' => lang('zen_general.markup.markdown'),
      'textile'  => lang('zen_general.markup.textile'),
      'plain'    => lang('zen_general.markup.plain'),
      'html'     => lang('zen_general.markup.html')
    }

    class << self
      include ::Ramaze::Helper::CGI

      ##
      # Converts markup using the specified markup engine.
      #
      # @example
      #  Zen::Markup.conver(:markdown, 'Hello **world**')
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [#to_s] engine The markup engine to use.
      # @param  [String] markup The markup to convert.
      # @return [String]
      #
      def convert(engine, markup)
        unless Registered.keys.include?(engine.to_s)
          raise(ArgumentError, "The specified engine \"#{engine}\" is invalid")
        end

        return send(engine, markup)
      end

      private

      ##
      # Converts the Markdown markup to HTML using RDiscount.
      #
      # @example
      #  Zen::Markup.markdown('Hello **world**')
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The Markdown string to convert to HTML.
      # @return [String] The HTML returned by RDiscount.
      #
      def markdown(markup)
        unless Kernel.const_defined?(:RDiscount)
          Ramaze.setup(:verbose => false) do
            gem 'rdiscount'
          end
        end

        return RDiscount.new(markup).to_html
      end

      ##
      # Converts Textile to HTML using RedCloth.
      #
      # @example
      #  Zen::Markup.textile('Hello *world*')
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [String] markup The Textile markup to convert to HTML.
      # @return [String] The HTML returned by RedCloth.
      #
      def textile(markup)
        unless Kernel.const_defined?(:RedCloth)
          Ramaze.setup(:verbose => false) do
            gem 'RedCloth', :lib => 'redcloth'
          end
        end

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
    end # class << self
  end # Markup
end # Zen
