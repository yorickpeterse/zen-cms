#:nodoc:
module Zen
  #:nodoc:
  module Theme
    ##
    # Base class used for all themes.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Base
      include ::Zen::Validation

      # The name of the theme
      attr_accessor :name

      # The author of the theme
      attr_accessor :author

      # A small description of the theme
      attr_accessor :about

      # The URL to the theme's homepage
      attr_accessor :url

      # Path to the directory containing all templates
      attr_accessor :template_dir

      # Path to the directory containing all template partials
      attr_accessor :partial_dir

      # Path to the theme's public directory (useful for CSS and Javascript files)
      attr_accessor :public_dir

      # Path to the directory containing all migrations for the theme
      attr_accessor :migration_dir

      ##
      # Validates all attributes of this class.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def validate
        validates_presence([:name, :author, :about, :template_dir])
        validates_format(:name, /[a-z0-9_\-]+/)

        # Validate all the directories
        validates_filepath(:template_dir)

        [:partial_dir, :public_dir, :migration_dir].each do |m|
          if !send(m).nil?
            validates_filepath(m)
          end
        end

        # Check if the theme hasn't already been registered
        if ::Zen::Theme::Registered.key?(name.to_sym)
          raise(::Zen::ValidationError, "The theme #{name} has already been registered.")
        end
      end

    end
  end
end
