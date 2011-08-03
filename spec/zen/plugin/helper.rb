require File.expand_path('../../../helper', __FILE__)

describe('Zen::Plugin::Helper') do
  extend ::Zen::Plugin::Helper

  it("Validate the type of a variable") do
    should.raise?(TypeError) do
      validate_type(10, :number, String)
    end
  end
end
