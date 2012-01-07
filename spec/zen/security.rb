require File.expand_path('../../helper', __FILE__)

describe('Zen::Security') do
  describe('Zen::Security.sanitize') do
    it('Escape <?r and ?> tags') do
      Zen::Security.sanitize('<?r puts "Hello" ?>').should == '\<\?r puts "Hello" \?\>'

      instance = Struct.new(:number).new(10)

      Innate::Etanni.new(Zen::Security.sanitize('<?r number = 15 ?>')).result(instance)

      instance.number.should == 10
    end

    it('Escape #{} tags') do
      Zen::Security.sanitize('#{name}').should == '\#\{name\}'

      instance = Struct.new(:number).new(10)

      output = Innate::Etanni.new(Zen::Security.sanitize('#{number}')).result(instance)

      output.should == '#{number}'
    end
  end
end
