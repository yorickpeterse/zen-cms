module Ramaze
  module Helper
    ##
    # {Ramaze::Helper::StackedAspect} is a helper very similar to
    # ``Innate::Helper::Aspect`` but comes with the ability to stack
    # before/after actions rather than overwriting previously defined ones.
    #
    # The methods in this module share similar names with the ones defined in
    # the original aspect helper except they're prefixed with ``stacked_``.
    #
    # Basic usage is as following:
    #
    #     class Foobar < Ramaze::Controller
    #       helper :stacked_aspect
    #
    #       stacked_before(:index) do
    #         @number = 0
    #       end
    #
    #       stacked_before(:index) do
    #         @number += 10
    #       end
    #
    #       def index
    #         return @number # => 10
    #       end
    #     end
    #
    # @since 04-11-2011
    #
    module StackedAspect
      # Hash containing the actions to call, similar to
      # Innate::Helper::Aspect::AOP.
      STACK = {}

      ##
      # Called whenever this module is included into a class.
      #
      # @since 04-11-2011
      #
      def self.included(into)
        into.helper(:aspect)
        into.extend(ClassMethods)
      end

      ##
      # Module containing various methods that can be used as class methods
      # inside the including class.
      #
      # @since 04-11-2011
      #
      module ClassMethods
        ##
        # Block that is executed before all actions in a controller.
        #
        # @since 04-11-2011
        #
        def stacked_before_all(&block)
          STACK[self]              ||= {}
          STACK[self][:before_all] ||= []
          STACK[self][:before_all]  << block

          before_all do
            STACK[self.class][:before_all].each do |b|
              instance_eval(&b)
            end
          end
        end

        ##
        # Block that is executed before a specific list of actions.
        #
        # @since 04-11-2011
        #
        def stacked_before(*names, &block)
          STACK[self] ||= {}

          names.each do |name|
            STACK[self][:before]       ||= {}
            STACK[self][:before][name] ||= []
            STACK[self][:before][name]  << block

            before(name) do
              STACK[self.class][:before][name].each do |b|
                instance_eval(&b)
              end
            end
          end
        end

        ##
        # Block that is executed after all actions.
        #
        # @since 04-11-2011
        #
        def stacked_after_all(&block)
          STACK[self]             ||= {}
          STACK[self][:after_all] ||= []
          STACK[self][:after_all]  << block

          before_all do
            STACK[self.class][:after_all].each do |b|
              instance_eval(&b)
            end
          end
        end

        ##
        # Block that is run after a specific list of actions.
        #
        # @since 04-11-2011
        #
        def stacked_after(*names, &block)
          STACK[self] ||= {}

          names.each do |name|
            STACK[self][:after]       ||= {}
            STACK[self][:after][name] ||= []
            STACK[self][:after][name]  << block

            before(name) do
              STACK[self.class][:after][name].each do |b|
                instance_eval(&b)
              end
            end
          end
        end

        ##
        # Wraps a block around a list of actions.
        #
        # @since 04-11-2011
        #
        def stacked_wrap(*names, &block)
          before(*names, &block)
          after(*names, &block)
        end
      end # ClassMethods
    end # StackedAspect
  end # Helper
end # Ramaze
