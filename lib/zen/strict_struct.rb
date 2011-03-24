#:nodoc:
module Zen
  ##
  # StrictStruct is a simple extension of the Struct class, it provides a method that
  # checks if all getters/setters have a value and if one doesn't it will call the
  # appropriate block.
  #
  # @author Yorick Peterse
  # @since  0.2.4
  #
  class StrictStruct < Struct

    ##
    # Validates all getter/setters in the current class to see if all values are set.
    #
    # @example
    #  struct = Zen::StrictStruct.new(:name, :age).new
    #  struct.validate([:name, :age]) do |k|
    #    puts "The key #{k} is required!"
    #  end
    #  
    # @author Yorick Peterse
    # @since  0.2.4
    # @param  [Array] required Array of getters that should return a value.
    # @param  [Block] block The block to call whenever an item doesn't have a value.
    #
    def validate(required, &block)
      required.each do |k|
        if !self.respond_to?(k) or self.send(k).nil?
          block.call(k)
        end
      end
    end

  end
end
