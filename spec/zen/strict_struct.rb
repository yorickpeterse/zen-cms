require_relative('../helper')

describe("Zen::StrictStruct") do

  it("Create a new StrictStruct object") do
    obj = Zen::StrictStruct.new(:name, :age, :location).new

    obj.respond_to?(:name).should     === true
    obj.respond_to?(:age).should      === true
    obj.respond_to?(:location).should === true
  end

  it("Validate an instance") do
    obj     = Zen::StrictStruct.new(:name, :age, :location).new
    missing = []

    obj.validate([:name, :age]) do |k|
      missing.push(k)
    end

    missing.include?(:name).should     === true
    missing.include?(:age).should      === true
    missing.include?(:location).should === false
  end

end
