require __DIR__('../error/theme_error')

#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper that provides a few methods that make certain tasks easier when creating
    # themes and templates.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    module Theme

      ##
      # Renders a partial from the current theme's partial directory. The first argument
      # is the name of the partial (without an extension) to render. The second argument
      # is a hash with variables that should be made available to the partial.
      #
      # @example
      #  partial(:header) # => partials/header.xhtml
      #  partial(:header, :username => "YorickPeterse")
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Symbol] file The name of the partial to render.
      # @param  [Hash] variables A hash with variables that should be made available for
      # the partial.
      #
      def partial(file, variables = {})
        theme = ::Zen::Theme[@settings[:theme]]

        if !theme.respond_to?(:partial_dir) or theme.partial_dir.nil?
          raise(::Zen::ThemeError, "The theme #{theme.name} has no partial directory set.")
        end

        template = "#{theme.partial_dir}/#{file}.xhtml"

        if !File.exist?(template)
          raise(::Zen::ThemeError, "The template #{template} doesn't exist.")
        end

        # All done captain!
        render_file(template, variables)
      end

      ##
      # Renders the 404 template for the current theme (clearing the current buffer) and
      # sets the HTTP response code to 404. Optionally you can pass a set of variables to
      # the 404 template by setting this method's first argument to a hash.
      #
      # @example
      #  show_404
      #  show_404(:uri => @request_uri)
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @param  [Hash] variables Hash with variables to pass to the 404 template.
      #
      def show_404(variables = {})
        theme    = ::Zen::Theme[@settings[:theme]]
        template = "#{theme.template_dir}/404.xhtml"

        # Render the template and replace the current buffer with it's output
        template = render_file(template, variables)

        respond(template, 404)
      end

    end
  end
end
