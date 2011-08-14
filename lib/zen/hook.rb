#:nodoc:
module Zen
  ##
  # Zen::Hook is a module that can be used to register and execute hooks. Hooks
  # are small Procs that are executed before or after something has happened.
  # Hooks can be useful when you want to send an Email after a certain record
  # has been added without having to monkey patch a particular model (which
  # would overwrite any existing hooks).
  #
  # Adding a hook can be done by calling Zen::Hook.add as following:
  #
  #     Zen::Hook.add(:hook_name) do
  #
  #     end
  #
  # The block that's added to the Zen::Hook.add() takes any number of parameters
  # depending on the ones passed to Zen::Hook.call(). For example, if the hook
  # is called and passed two parameters both parameters will be passed to the
  # hook's block.
  #
  # Hooks are executed in their own thread and are automatically wrapped in a
  # mutex. While this will not make it a lot faster or actually run concurrently
  # (thanks to the GIL) it's a nice way of ensuring hooks are isolated from each
  # other.
  #
  # ## Example
  #
  #     Zen::Hook.add(:greet) do |amount, name|
  #       amount.times do
  #         puts "Hello #{name}"
  #       end
  #     end
  #
  #     Zen::Hook.call(:greet, 10, 'Ruby')
  #
  # This would result in "Hello Ruby" being printed 10 times in the console.
  #
  # @author Yorick Peterse
  # @since  0.2.9
  #
  module Hook
    # Hash containing all the hook names and a list of procs to execute for all
    # those hooks.
    Registered = {}

    ##
    # Runs all the hooks for the name and passes the arguments to each hook.
    # Each hook is run in it's own thread and is wrapped in a mutex.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] hook The name of the hook to invoke.
    # @param  [Array] *args An array of arguments to pass to each hook.
    #
    def self.call(hook, *args)
      hook    = hook.to_sym
      threads = []
      mutex   = Mutex.new

      if Registered.key?(hook)
        # Each hook is executed in it's own thread.
        Registered[hook].each do |hook|
          threads << Thread.new do
            mutex.synchronize do
              hook.call(*args)
            end
          end
        end

        # Wait for all the threads (if there are any) to finish.
        if !threads.empty?
          threads.each do |thread|
            thread.join
          end
        end
      end
    end

    ##
    # Adds a new hook to the list of hooks for the given name.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] hook The name of the hook.
    # @param  [Proc] block A block to execute when the hook is invoked.
    #
    def self.add(hook, &block)
      hook               = hook.to_sym
      Registered[hook] ||= []

      Registered[hook].push(block)
    end
  end # Hook
end # Zen
