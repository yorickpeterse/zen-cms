require __DIR__('../error/theme_error')

#:nodoc:
module Ramaze
  #:nodo:"
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

    end
  end
end
