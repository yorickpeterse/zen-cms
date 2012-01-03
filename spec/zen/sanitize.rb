require File.expand_path('../../helper', __FILE__)

describe('Zen.sanitize') do
  it('Escape <?r and ?> tags') do
    Zen.sanitize('<?r puts "Hello" ?>').should == '\<\?r puts "Hello" \?\>'

    instance = Struct.new(:number).new(10)

    Innate::Etanni.new(Zen.sanitize('<?r number = 15 ?>')).result(instance)

    instance.number.should == 10
  end

  it('Escape #{} tags') do
    Zen.sanitize('#{name}').should == '\#\{name\}'

    instance = Struct.new(:number).new(10)

    output = Innate::Etanni.new(Zen.sanitize('#{number}')).result(instance)

    output.should == '#{number}'
  end
end
