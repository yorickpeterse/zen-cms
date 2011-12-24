#:nodoc:
module Sequel
  #:nodoc:
  module Plugins

    # The Sluggable plugin creates hook that automatically sets
    # 'slug' field to the slugged value of the column specified
    # by :source option.
    #
    # You need to have "target" column in your model.
    module Sluggable
      #:nodoc:
      DEFAULT_TARGET_COLUMN = :slug

      # Plugin configuration
      def self.configure(model, opts={})
        model.sluggable_options = opts
        model.sluggable_options.freeze

        model.class_eval do
          # Sets the slug to the normalized URL friendly string
          #
          # Compute slug for the value
          #
          # @param [String] String to be slugged
          # @return [String]
          define_method("#{sluggable_options[:target]}=") do |value|
            sluggator = self.class.sluggable_options[:sluggator]

            if sluggator.respond_to?(:call)
              slug = sluggator.call(value, self)
            end

            if sluggator
              slug ||= self.send(sluggator, value)
            end

            # If a slug is an empty string or a nil value it's value should be
            # pulled from the source attribute.
            if value.nil? or (value.respond_to?(:empty?) and value.empty?)
              slug = to_slug(self.send(self.class.sluggable_options[:source]))
            end

            slug ||= to_slug(value)

            super(slug)
          end
        end

      end

      #:nodoc:
      module ClassMethods
        attr_reader :sluggable_options

        # Finds model by slug or PK
        #
        # @return [Sequel::Model, nil]
        def find_by_pk_or_slug(value)
          value.to_s =~ /^\d+$/ ? self[value] : self.find_by_slug(value)
        end

        # Finds model by Slug column
        #
        # @return [Sequel::Model, nil]
        def find_by_slug(value)
          self[@sluggable_options[:target] => value.chomp]
        end

        # Propagate settings to the child classes
        #
        # @param [Class] Child class
        def inherited(klass)
          super
          klass.sluggable_options = self.sluggable_options.dup
        end

        # Set the plugin options
        #
        # Options:
        # @param [Hash] plugin options
        # @option frozen    [Boolean]      :Is slug frozen, default true
        # @option sluggator [Proc, Symbol] :Algorithm to convert string to slug.
        # @option source    [Symbol] :Column to get value to be slugged from.
        # @option target    [Symbol] :Column to write value of the slug to.
        def sluggable_options=(options)
          raise ArgumentError, "You must provide :source column" unless options[:source]
          sluggator = options[:sluggator]
          if sluggator && !sluggator.is_a?(Symbol) && !sluggator.respond_to?(:call)
            raise ArgumentError, "If you provide :sluggator it must be Symbol or callable."
          end
          options[:source]    = options[:source].to_sym
          options[:target]    = options[:target] ? options[:target].to_sym : DEFAULT_TARGET_COLUMN
          options[:frozen]    = options[:frozen].nil? ? true : !!options[:frozen]
          @sluggable_options  = options
        end
      end

      #:nodoc:
      module InstanceMethods

        # Sets a slug column to the slugged value
        def before_create
          super
          target = self.class.sluggable_options[:target]
          set_target_column unless self.send(target)
        end

        # Sets a slug column to the slugged value
        def before_update
          super
          target = self.class.sluggable_options[:target]
          frozen = self.class.sluggable_options[:frozen]
          set_target_column if !self.send(target) || !frozen
        end

        private

        # Generate slug from the passed value
        #
        # @param [String] String to be slugged
        # @return [String]
        def to_slug(value)
          value.chomp.downcase.gsub(/[^a-z0-9_]+/, '-')
        end

        # Sets target column with source column which
        # effectively triggers slug generation
        def set_target_column
          target = self.class.sluggable_options[:target]
          source = self.class.sluggable_options[:source]
          self.send("#{target}=", self.send(source))
        end
      end # InstanceMethods
    end # Sluggable
  end # Plugins
end # Sequel
