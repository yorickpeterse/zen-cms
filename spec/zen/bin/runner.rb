require File.expand_path('../../../helper', __FILE__)

describe('Zen::Bin::Runner') do
  @bin_path = __DIR__('../../../bin/zen')

  it('Show the help message') do
    output   = `#{@bin_path}`
    expected = <<TXT
Zen is a modular CMS written using Ramaze

Usage:
  zen [COMMAND] [OPTIONS]

Available Commands:
  app: Creates a new application prototype

Options:
  -v, --version                    Shows the version of Zen
  -h, --help                       Shows this help message
TXT

    output.should === expected
  end

  it('Show the help message using -h') do
    output   = `#{@bin_path} -h`
    expected = <<TXT
Zen is a modular CMS written using Ramaze

Usage:
  zen [COMMAND] [OPTIONS]

Available Commands:
  app: Creates a new application prototype

Options:
  -v, --version                    Shows the version of Zen
  -h, --help                       Shows this help message
TXT

    output.should === expected
  end

  it('Show the version number') do
    output = `#{@bin_path} -v`.strip

    output.should === Zen::Version
  end

end
