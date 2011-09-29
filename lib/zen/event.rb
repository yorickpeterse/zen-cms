#:nodoc:
module Zen
  ##
  # Zen::Event is a module that can be used to register and execute events.
  # Events are small Procs that are executed before or after something has
  # happened. Events can be useful when you want to send an Email after a
  # certain record has been added without having to monkey patch a particular
  # model (which would overwrite any existing events).
  #
  # It's important to remember that events are based on the idea of "fire and
  # forget". This means that Zen will not do anything with any return values or
  # wait for an event to finish executing.
  #
  # Adding a event can be done by calling Zen::Event.listen as following:
  #
  #     Zen::Event.listen(:event_name) do
  #
  #     end
  #
  # The block that's added to the Zen::Event.listen() takes any number of
  # parameters depending on the ones passed to Zen::Event.call(). For example,
  # if the event is called and passed two parameters both parameters will be
  # passed to the event's block.
  #
  # Events are executed in their own thread and are automatically wrapped in a
  # mutex. While this will not make it a lot faster or actually run concurrently
  # (thanks to the GIL) it's a nice way of ensuring events are isolated from
  # each other.
  #
  # ## Example
  #
  #     Zen::Event.listen(:greet) do |amount, name|
  #       amount.times do
  #         puts "Hello #{name}"
  #       end
  #     end
  #
  #     Zen::Event.call(:greet, 10, 'Ruby')
  #
  # This would result in "Hello Ruby" being printed 10 times in the console.
  #
  # @author Yorick Peterse
  # @since  0.2.9
  #
  module Event
    # Hash containing all the event names and a list of procs to execute for all
    # those events.
    Registered = {}

    ##
    # Runs all the events for the name and passes the arguments to each event.
    # Each event is run in it's own thread and is wrapped in a mutex.
    #
    # @example
    #  Zen::Event.call(:new_user, User[1])
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] event The name of the event to invoke.
    # @param  [Array] *args An array of arguments to pass to each event.
    #
    def self.call(event, *args)
      event    = event.to_sym
      threads = []
      mutex   = Mutex.new

      if Registered.key?(event)
        # Each event is executed in it's own thread.
        Registered[event].each do |event|
          threads << Thread.new do
            mutex.synchronize do
              event.call(*args)
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
    # Adds a new event to the list of events for the given name. If the event
    # does not exist it will be created automatically.
    #
    # @example
    #  Zen::Event.listen(:new_user) do |user|
    #    puts user.name
    #  end
    #
    # @author Yorick Peterse
    # @since  0.2.9
    # @param  [#to_sym] event The name of the event.
    # @param  [Proc] block A block to execute when the event is invoked.
    #
    def self.listen(event, &block)
      event               = event.to_sym
      Registered[event] ||= []

      Registered[event].push(block)
    end
  end # Event
end # Zen
