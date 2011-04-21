require File.expand_path('../../helper', __FILE__)

class ValidationObject
  include ::Zen::Validation

  attr_accessor :name

  def presence
    validates_presence(:name)
  end

  def length
    validates_length(:name, :min => 3, :max => 5)
  end

  def format
    validates_format(:name, /[a-z]+/)
  end
end

describe('Zen::Validation') do

  it('Validate the presence of an attribute') do
    object = ValidationObject.new

    lambda { object.presence }.should raise_error(Zen::ValidationError)

    # Now validate it with a value
    object.name = 'yorick'

    lambda { object.presence }.should_not raise_error(Zen::ValidationError)
  end

  it('Validate the length of an attribute') do
    object = ValidationObject.new

    lambda { object.length }.should raise_error(Zen::ValidationError)

    # Too short
    object.name = 'ab'

    lambda { object.length }.should raise_error(Zen::ValidationError)

    # Too long
    object.name = 'abcdef'

    lambda { object.length }.should raise_error(Zen::ValidationError)

    # Perfect
    object.name = 'ab3'

    lambda { object.length }.should_not raise_error(Zen::ValidationError)
  end

  it('Validate the format of an attribute') do
    object      = ValidationObject.new
    object.name = 10

    lambda { object.format }.should raise_error(Zen::ValidationError)

    object.name = 'hello'

    lambda { object.format }.should_not raise_error(Zen::ValidationError)
  end

end
