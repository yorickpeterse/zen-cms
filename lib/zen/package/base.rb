#:nodoc:
module Zen
  #:nodoc:
  module Package
    ##
    # Base class used to store the data about packages such as the name, directory, etc.
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    class Base
      include ::Zen::Validation

      # The name of the package
      attr_accessor :name

      # The author of the package
      attr_accessor :author

      # A small description about the package
      attr_accessor :about

      # The URL to the website of the package
      attr_accessor :url

      # The root directory of the package
      attr_accessor :directory

      # Array containing the navigation items for the package
      attr_accessor :menu

      # Path to the directory containing all migrations
      attr_accessor :migration_dir

      # Array containing all controllers for the package. These classes will be used
      # by the ACL system.
      attr_accessor :controllers

      ##
      # Validates all the attributes.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      #
      def validate
        validates_presence([:name, :author, :about, :directory, :controllers])
        validates_format(:name, /[a-z0-9_\-]+/)
        validates_filepath(:directory)

        if !migration_dir.nil?
          validates_filepath(:migration_dir)
        end

        # Check if the package hasn't been registered yet
        if ::Zen::Package::Registered.key?(name.to_sym)
          raise(::Zen::ValidationError, "The package #{name} already exists.")
        end
      end

    end
  end
end
