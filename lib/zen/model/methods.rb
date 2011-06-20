#:nodoc:
module Sequel
  #:nodoc:
  class Model
    ##
    # Retrieves all primary values and an optional column and returns the 
    # results as an array of hashes in which the keys of these hashes are the 
    # IDs and the values the values of the specified column. This array can be 
    # used when creating <select> elements using the BlueForm helper.
    #
    # @example
    #  Sections::Model::Section.pk_hash(:name) # => {1 => 'Blog', 2 => 'General'}
    #
    # @author Yorick Peterse
    # @param  [Symbol] column The name of the optional column to select.
    # @return [Hash]
    #
    def self.pk_hash column
      hash = {}
      
      self.select(:id, column.to_sym).each do |row|
        hash[row.id] = row.send(column)
      end
      
      return hash
    end
  end # Model
end # Sequel
