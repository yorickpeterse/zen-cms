require File.expand_path('../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'validation')
require 'fileutils'

describe('Zen::Validation') do

  should('validate the presence of an attribute') do
    object = ValidationObject.new

    should.raise?(Zen::ValidationError) { object.presence }

    # Now validate it with a value
    object.name = 'yorick'

    should.not.raise?(Zen::ValidationError) { object.presence }
  end

  should('validate the length of an attribute') do
    object = ValidationObject.new

    should.raise?(Zen::ValidationError) { object.length }

    # Too short
    object.name = 'ab'

    should.raise?(Zen::ValidationError) { object.length }

    # Too long
    object.name = 'abcdef'

    should.raise?(Zen::ValidationError) { object.length }

    # Perfect
    object.name = 'ab3'

    should.not.raise?(Zen::ValidationError) { object.length }
  end

  should('validate the format of an attribute') do
    object      = ValidationObject.new
    object.name = 10

    should.raise?(Zen::ValidationError) { object.format }

    object.name = 'hello'

    should.not.raise?(Zen::ValidationError) { object.format }
  end

  should('validate a file') do
    object      = ValidationObject.new
    object.file = '/tmp/zen_validation'

    should.raise?(Zen::ValidationError) { object.exists }

    FileUtils.touch('/tmp/zen_validation')

    should.not.raise?(Zen::ValidationError) { object.exists }

    File.unlink('/tmp/zen_validation')
  end

end
