require File.expand_path('../../../helper', __FILE__)

describe('Zen::Plugin::Helper') do
  include ::Zen::Plugin::Helper

  it("Validate the type of a variable") do
    lambda { validate_type(10, :number, String) }.should raise_error(TypeError)
  end
end
