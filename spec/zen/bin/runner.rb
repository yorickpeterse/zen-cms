require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../../lib/zen/bin/runner')

describe('Zen::Bin::Runner') do
  @bin_path = __DIR__('../../../bin/zen')

  it('Show the help message') do
    output   = `#{@bin_path}`
    output.include?(Zen::Bin::Runner::Banner).should === true
  end

  it('Show the help message using -h') do
    output   = `#{@bin_path} -h`
    output.include?(Zen::Bin::Runner::Banner).should === true  end

  it('Show the version number') do
    output = `#{@bin_path} -v`.strip

    output.should === Zen::Version
  end

end
