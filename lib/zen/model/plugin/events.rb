module Sequel
  module Plugins
    ##
    # Plugin for Sequel that acts as a bridge between Sequel hooks and events
    # fired by {Zen::Event}. Based on the specified options it creates events
    # for the following Sequel hooks:
    #
    # * before_create
    # * after_create
    # * before_update
    # * after_update
    # * before_destroy
    # * after_destroy
    #
    # For example, to add the Zen event "before_new_post" and have it called by
    # the Sequel hook "before_create" you'd do the following:
    #
    #  class Posts < Sequel::Model
    #    plugin :events, :before_create => :before_new_post
    #  end
    #
    # Each event will receive an instance of the model. This means that you're
    # free to modify the model in your events as long as you take into account
    # that other events might do the same:
    #
    #     Zen::Event.listen(:before_new_post) do |post|
    #       post.title = 'a'
    #     end
    #
    # Events don't have to return the modified object as objects are assigned by
    # reference.
    #
    # @since 05-02-2012
    #
    module Events
      ##
      # Configures the plugin for a single model.
      #
      # @since 06-02-2012
      # @param [Class] model The model for which to enable the plugin.
      # @param [Hash] options A hash containing the Sequel hook names and the
      #  Zen events to fire.
      # @option options [Symbol] :before_create The name of the event to call in
      #  the before_create hook.
      # @option options [Symbol] :after_create The name of the event to call in
      #  the after_create hook.
      # @option options [Symbol] :before_update The name of the event to call in
      #  the before_update hook.
      # @option options [Symbol] :after_update The name of the event to call in
      #  the after_update hook.
      # @option options [Symbol] :before_destroy The name of the event to call
      #  in the before_destroy hook.
      # @option options [Symbol] :after_destroy The name of the event to call in
      #  the after_destroy hook.
      #
      def self.configure(model, options = {})
        model.events = options
      end

      ##
      # Module containing the methods and attributes to make available on class
      # level.
      #
      # @since 06-02-2012
      #
      module ClassMethods
        # Hash containing all the Sequel hooks and the corresponding Zen events.
        attr_accessor :events
      end

      ##
      # Module containing the methods and attributes to make available on
      # instance leve.
      #
      # @since 06-02-2012
      #
      module InstanceMethods
        ##
        # Hook executed before creating a new object.
        #
        # @since 06-02-2012
        #
        def before_create
          if self.class.events and self.class.events.key?(:before_create)
            Zen::Event.call(self.class.events[:before_create], self)
          end

          super
        end

        ##
        # Hook executed after creating a new object.
        #
        # @since 06-02-2012
        #
        def after_create
          super

          if self.class.events and self.class.events.key?(:after_create)
            Zen::Event.call(self.class.events[:after_create], self)
          end
        end

        ##
        # Hook executed before updating an existing object.
        #
        # @since 06-02-2012
        #
        def before_update
          if self.class.events and self.class.events.key?(:before_update)
            Zen::Event.call(self.class.events[:before_update], self)
          end

          super
        end

        ##
        # Hook executed after updating an existing object.
        #
        # @since 06-02-2012
        #
        def after_update
          super

          if self.class.events and self.class.events.key?(:after_update)
            Zen::Event.call(self.class.events[:after_update], self)
          end
        end

        ##
        # Hook executed before removing an existing object.
        #
        # @since 06-02-2012
        #
        def before_destroy
          if self.class.events and self.class.events.key?(:before_destroy)
            Zen::Event.call(self.class.events[:before_destroy], self)
          end

          super
        end

        ##
        # Hook executed after removing an existing object.
        #
        # @since 06-02-2012
        #
        def after_destroy
          super

          if self.class.events and self.class.events.key?(:after_destroy)
            Zen::Event.call(self.class.events[:after_destroy], self)
          end
        end
      end # InstanceMethods
    end # Events
  end # Plugins
end # Sequel
