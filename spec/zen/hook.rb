require File.expand_path('../../helper', __FILE__)

describe('Zen::Hook') do
  after do
    Zen::Hook::Registered.delete(:test)
  end

  it('Register a hook') do
    Zen::Hook.add(:test) {}

    Zen::Hook::Registered.key?(:test).should === true
  end

  it('Run a single hook') do
    data = 0

    Zen::Hook.add(:test) do |number|
      data = number
    end

    Zen::Hook.call(:test, 10)
    data.should === 10

    Zen::Hook.call(:test, 12)
    data.should === 12
  end

  it('Run multiple hooks') do
    data = 0

    Zen::Hook.add(:test) do |number|
      data += number
    end

    Zen::Hook.add(:test) do |number|
      data += (number * 2)
    end

    Zen::Hook.call(:test, 10)
    Zen::Hook.call(:test, 20)

    data.should === 90
  end
end
