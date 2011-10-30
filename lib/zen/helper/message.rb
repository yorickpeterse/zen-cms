require 'ramaze/gestalt'

#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # The Mesage helper is a Ruby implementation of the Codeigniter library 
    # "Message" (located here: https://github.com/isset/codeigniter-message). 
    # This helper was taken from another project of mine which can be found here:
    # https://github.com/yorickpeterse/stumpert/
    #
    # ## Usage
    #
    # Basic usage is as following:
    #
    #     message(:error, "Bummer, something went wrong!")
    #
    # In your layout you'd do the following:
    #
    #     display_messages
    #
    # This will create and return the HTML for all the messages.
    #
    # @since  26-05-2011
    #
    module Message
      ##
      # Adds a new message to the list for the given type.
      #
      # @since  26-05-2011
      # @param  [Symbol/String] type The type of message to store (e.g. "error").
      # @param  [String] message The message to display.
      #
      def message(type, message)
        if type.respond_to?(:to_sym)
          type = type.to_sym
        end

        flash[:messages]       ||= {}
        flash[:messages][type] ||= []
        flash[:messages][type].push(message)
      end

      ##
      # Renders all the messages for the specified types.
      #
      # @since  26-05-2011
      # @param  [Array] types Array containing all the messages to render.
      #
      def display_messages(types = [:info, :error, :success])
        gestalt = ::Ramaze::Gestalt.new

        return if flash[:messages].nil?
        
        gestalt.div(:id => 'message_container', :class => 'container') do
          # Render each individual group
          types.each do |type|
            if type.respond_to?(:to_sym)
              type = type.to_sym
            end

            if flash[:messages].key?(type)
              gestalt.div(:class => "message #{type}") do
                # Render all the messages
                flash[:messages][type].each_with_index do |message, index|
                  flash[:messages][type].delete_at(index)
                  gestalt.p { message }
                end
              end
            end
          end
        end

        return gestalt.to_s
      end
    end # Message
  end # Helper
end # Ramaze
