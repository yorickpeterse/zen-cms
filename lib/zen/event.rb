#:nodoc:
module Zen
  ##
  # Zen::Event is a module that can be used to register and execute events.
  # Events are small Procs that are executed before or after something has
  # happened. Events can be useful when you want to send an Email after a
  # certain record has been added without having to monkey patch a particular
  # model (which would overwrite any existing events). Events can also be used
  # to modify data at certain points in your application. For example, you might
  # have an event that changes a comment's status before inserting it into the
  # database.
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
  # Events are called in sequence and each event will receive the same
  # parameters (given they take the same parameters). This means that if you
  # have 5 events each event could potentially receive different data depending
  # on whether a previous event modified the data. This is illustrated in the
  # following example:
  #
  #     obj = Struct.new(:name).new('Python')
  #
  #     Zen::Event.listen(:event_1) do |obj|
  #       obj.name = 'Ruby'
  #     end
  #
  #     Zen::Event.listen(:event_1) do |obj|
  #       obj.name = 'Perl'
  #     end
  #
  #     Zen::Event.call(:event_1, obj)
  #
  #     puts obj.name # => "Perl"
  #
  # @example Prints "Hello Ruby" 10 times
  #  Zen::Event.listen(:greet) do |amount, name|
  #    amount.times do
  #      puts "Hello #{name}"
  #    end
  #  end
  #
  #  Zen::Event.call(:greet, 10, 'Ruby')
  #
  # @since  0.3
  #
  module Event
    # Hash containing all the event names and a list of procs to execute for all
    # those events.
    Registered = {}

    class << self
      ##
      # Runs all the events for the name and passes the arguments to each event.
      # Each event is run in it's own thread and is wrapped in a mutex.
      #
      # @example
      #  Zen::Event.call(:new_user, User[1])
      #
      # @since  0.3
      # @param  [#to_sym] event The name of the event to invoke.
      # @param  [Array] *args An array of arguments to pass to each event.
      #
      def call(event, *args)
        event = event.to_sym

        if Registered.key?(event)
          Registered[event].each do |event|
            event.call(*args)
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
      # @since  0.3
      # @param  [#to_sym] event The name of the event.
      # @param  [Proc] block A block to execute when the event is invoked.
      #
      def listen(event, &block)
        event               = event.to_sym
        Registered[event] ||= []

        Registered[event].push(block)
      end

      ##
      # Removes all events for the given names.
      #
      # @example
      #  Zen::Event.delete(:before_new_user, :after_new_user)
      #
      # @since  0.3
      # @param  [Array] *names The names of the events to remove. Each name
      #  should be a symbol or something that responds to #to_sym().
      #
      def delete(*names)
        names.each do |name|
          Registered.delete(name.to_sym)
        end
      end
    end # class << self
  end # Event
end # Zen
