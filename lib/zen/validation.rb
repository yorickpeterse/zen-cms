module Zen
  ##
  # The Validation module is a very basic validation framework that's used by
  # various internal modules/classes such as Zen::Plugin and Zen::Package.
  #
  # ## Usage
  #
  # Using the module is pretty simple. Include it, specify the validation rules
  # in a method and call it. All official modules and classes use a method
  # called "validate" but you're free to name it whatever you want. A basic
  # example looks like the following:
  #
  #     class Something
  #       include Zen::Validation
  #
  #       attr_accessor :name
  #
  #       def validate
  #         validates_presence(:name)
  #       end
  #     end
  #
  # @since  0.2.5
  #
  module Validation
    ##
    # Checks if the specified attributes exist and aren't set to nil.
    #
    # @example
    #  validates_presence(:name)
    #
    # @since  0.2.5
    # @param  [Array/Symbol/String] attributes Either a single or multiple
    #  attributes to validate.
    # @raise  [ValidationError] Raised whenever a attribute is missing or is
    #  set to nil.
    #
    def validates_presence(attributes)
      if attributes.class != Array
        attributes = [attributes]
      end

      attributes.each do |f|
        if !respond_to?(f) or send(f).nil?
          raise(ValidationError, "The attribute \"#{f}\" doesn't exist.")
        end
      end
    end

    ##
    # Checks if the length of a string matches the given length. You can specify
    # a minimum length, a maximum one as well as both.
    #
    # @example
    #  validates_length(:foobar, :min => 5, :max => 10)
    #
    # @since  0.2.5
    # @param  [String/Symbol] attribute The attribute to validate.
    # @param  [Hash] options Hash containing the options to use for determining
    #  how long the attribute's value should be.
    # @option options [Fixnum] :min The minimum length of the attribute's value.
    # @option options [Fixnum] :max The maximum length of the value.
    # @raise  [ValidationError] Raised then the value of the attribute isn't
    #  long or short enough.
    #
    def validates_length(attribute, options)
      value = send(attribute)

      if !value.respond_to?(:length)
        raise(
          ValidationError,
          "The length of \"#{attribute}\" can't be checked as the method " + \
            "\"length\" doesn't exist."
        )
      end

      # Time to validate the length
      length = value.length

      if options.key?(:min) and length < options[:min]
        raise(ValidationError, "The attribute \"#{attribute}\" is too short.")
      end

      if options.key?(:max) and length > options[:max]
        raise(ValidationError, "The attribute \"#{attribute}\" is too long.")
      end
    end

    ##
    # Checks if the given attributes match the specified regular expressions.
    # When a hash is specified the keys should be the names of the attributes to
    # validate and the values the regular expressions to use.
    #
    # @example
    #  validates_format(:name, /[\w\-]+/)
    #  validates_format(:name => /[\w\-]+/, :age => /[0-9]+/)
    #
    # @since  0.2.5
    # @param  [Hash/Symbol] attribute The name of the attribute to validate or
    #  a hash containing all the attributes and their regular expressions.
    # @param  [Regexp] regexp The regular expression to use when validating a
    #  single attribute.
    # @raise [ValidationError] Raised when one of the attributes doesn't matches
    #  the regular expression.
    #
    def validates_format(attribute, regexp = nil)
      if attribute.class != Hash
        attribute = {attribute => regexp}
      end

      # Try to match all attributes
      attribute.each do |attr, regexp|
        val   = send(attr)
        match = val =~ regexp

        if !match
          raise(
            ValidationError,
            "The attribute \"#{attr}\" doesn't match #{regexp}"
          )
        end
      end
    end

    ##
    # Checks if the specified attribute contains a valid file path.
    #
    # @example
    #  validates_filepath(:directory)
    #
    # @since  0.2.5
    # @param [String/Symbol] attribute The attribute to validate.
    # @raise [ValidationError] Raised when one of the paths didn't exist.
    #
    def validates_filepath(attribute)
      path = send(attribute)

      if !File.exist?(path)
        raise(
          ValidationError,
          "The path #{path} in \"#{attribute}\" doesn't exist."
        )
      end
    end
  end # Validation
end # Zen
