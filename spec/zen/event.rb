require File.expand_path('../../helper', __FILE__)

describe('Zen::Event') do
  after do
    Zen::Event::REGISTERED.delete(:test)
  end

  should('register a event') do
    Zen::Event.listen(:test) {}

    Zen::Event::REGISTERED.key?(:test).should == true
  end

  should('run a single event') do
    data = 0

    Zen::Event.listen(:test) do |number|
      data = number
    end

    Zen::Event.call(:test, 10)
    data.should == 10

    Zen::Event.call(:test, 12)
    data.should == 12
  end

  should('run multiple events') do
    data = 0

    Zen::Event.listen(:test) do |number|
      data += number
    end

    Zen::Event.listen(:test) do |number|
      data += (number * 2)
    end

    Zen::Event.call(:test, 10)
    Zen::Event.call(:test, 20)

    data.should == 90
  end
end
