module Ramaze
  module Helper
    ##
    # StackedAspect is a helper similar to Innate::Helper::Aspect but allows
    # calls to methods such as ``before_all`` to stack on top of each other
    # instead of overwriting previously defined ones.
    #
    # Although this helper works very similar to the Aspect helper there are two
    # main differences besides the calls being stackable:
    #
    # 1. All methods are prefixed with ``stacked_``
    # 2. All methods require you to specify a name for the block.
    #
    # Both these items exist to achieve compatibility with the Aspect helper as
    # well as being able to reload code using the reloader without adding all
    # the blocks each time the code is reloaded.
    #
    # Basic usage of this helper is as following:
    #
    #     class Posts < Ramaze::Controller
    #       map    '/posts'
    #       helper :stacked_aspect
    #
    #       stacked_before_all(:validate_ip) do
    #         validate_ip
    #       end
    #
    #       stacked_before_all(:validate_user) do
    #         validate_user
    #       end
    #
    #       def index
    #
    #       end
    #     end
    #
    # In this example both methods (``validate_ip`` and ``validate_user``) would
    # be executed before calling ``#index()``.
    #
    # @since 06-11-2011
    #
    module StackedAspect
      # Hash that will contain all the STACKED_AOP actions.
      STACKED_AOP = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = {} } }

      ##
      # Called whenever this module is included into a class.
      #
      # @since 06-11-2011
      # @param [Class] into The class that included this module.
      #
      def self.included(into)
        into.extend(ClassMethods)
        into.add_action_wrapper(7.0, :stacked_aspect_wrap)
      end

      # @see Innate::Helper::Aspect.ancestral_aop
      def self.ancestral_aop(from)
        aop = {}

        from.ancestors.reverse.map do |anc|
          aop.merge!(STACKED_AOP[anc]) if anc < StackedAspect
        end

        return aop
      end

      ##
      # Shows a warning to inform the developer that the aspect name is already
      # in use.
      #
      # @since 06-11-2011
      # @param [#to_s] name The name of the aspect.
      #
      def self.aspect_warn(name)
        file, line = caller[1].split(':')

        Ramaze::Log.warn(
          "The aspect name \"#{name}\" is already in use, it was redefined " \
            "in #{file} on line #{line}"
        )
      end

      ##
      # Calls a certain AOP action for the specified position and method name.
      #
      # @since 06-11-2011
      # @param [Symbol] position The position of the AOP action (e.g. :after).
      # @param [String] name The name of the method for which to call the
      #  action.
      #
      def stacked_aspect_call(position, name)
        return unless aop   = StackedAspect.ancestral_aop(self.class)
        return unless block = aop[position]

        name = name.to_sym

        # Bail out if the position is :before or :after but the current method
        # doesn't match.
        if [:before, :after].include?(position) and !block[name].is_a?(Hash)
          return
        end

        # Extract the sub hash for the current method, this is needed for
        # :before and :after.
        if block.is_a?(Hash) and block[name].is_a?(Hash)
          block = block[name]
        end

        if block.respond_to?(:each)
          block.each do |k, v|
            instance_eval(&v)
          end
        else
          instance_eval(&block)
        end
      end

      # @see Innate::Helper::Aspect#aspect_wrap
      def stacked_aspect_wrap(action)
        return yield unless method = action.name

        stacked_aspect_call(:before_all, method)
        stacked_aspect_call(:before, method)

        result = yield

        stacked_aspect_call(:after, method)
        stacked_aspect_call(:after_all, method)

        return result
      end

      ##
      # Module who's methods become available as class methods.
      #
      # @since 06-11-2011
      #
      module ClassMethods
        include Traited

        ##
        # Defines a block to run before all the actions in a controller.
        #
        # @example
        #  stacked_before_all(:check_ip) do
        #    validate_ip
        #  end
        #
        #  stacked_before_all(:check_username) do
        #    validate_username
        #  end
        #
        # @since 06-11-2011
        # @param [#to_sym] name The unique name of the block.
        # @param [Proc] block The block to execute.
        #
        def stacked_before_all(name, &block)
          name = name.to_sym

          if !STACKED_AOP[self][:before_all].key?(name)
            STACKED_AOP[self][:before_all][name] = block
          else
            StackedAspect.aspect_warn(name)
          end
        end

        ##
        # Defines a block similar to
        # {Ramaze::Helper::StackedAspect::ClassMethods#stacked_before} but only
        # runs the block before the specified list of methods.
        #
        # @example
        #  stacked_before(:check_ip, [:save, :delete]) do
        #    validate_ip
        #  end
        #
        # @since 06-11-2011
        # @param [#to_sym] name A unique name for the block.
        # @param [Array] methods An array of methods for which to run the block.
        # @param [Proc] block The block to run.
        #
        def stacked_before(name, methods, &block)
          name = name.to_sym

          methods.each do |m|
            m = m.to_sym
            STACKED_AOP[self][:before][m] ||= {}

            if !STACKED_AOP[self][:before][m].key?(name)
              STACKED_AOP[self][:before][m][name] = block
            else
              StackedAspect.aspect_warn(name)
            end
          end
        end

        ##
        # Runs a block after all the actions in a controller.
        #
        # @since 06-11-2011
        # @see   Ramaze::Helper::StackedAspect::ClassMethods#stacked_before_all
        #
        def stacked_after_all(name, &block)
          name = name.to_sym

          if !STACKED_AOP[self][:after_all].key?(name)
            STACKED_AOP[self][:after_all][name] = block
          else
            StackedAspect.aspect_warn(name)
          end
        end

        ##
        # Runs a block after a specific list of methods.
        #
        # @since 06-11-2011
        # @see   Ramaze::Helper::StackedAspect::ClassMethods#stacked_before
        #
        def stacked_after(name, names, &block)
          name = name.to_sym

          methods.each do |m|
            m = m.to_sym
            STACKED_AOP[self][:after][m] ||= {}

            if !STACKED_AOP[self][:after][m].key?(name)
              STACKED_AOP[self][:after][m][name] = block
            else
              StackedAspect.aspect_warn(name)
            end
          end
        end

        ##
        # Wraps the block around the list of methods.
        #
        # @since 06-11-2011
        # @see   Ramaze::Helper::StackedAspect::ClassMethods#stacked_before
        # @see   Ramaze::Helper::StackedAspect::ClassMethods#stacked_after
        #
        def stacked_wrap(name, names, &block)
          before(name, names, &block)
          after(name, names, &block)
        end
      end # ClassMethods
    end # StackedAspect
  end # Helper
end # Ramaze
