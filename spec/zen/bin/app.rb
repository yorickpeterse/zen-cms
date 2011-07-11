require File.expand_path('../../../helper', __FILE__)
require 'fileutils'

describe('Zen::Bin::App') do
  @bin_path = __DIR__('../../../bin/zen')

  it('Show the help message') do
    output   = `#{@bin_path} app`
    expected = <<TXT
Creates a new application prototype

Usage:
  zen app [NAME] [OPTIONS]

Example:
  zen app blog

Options:
  -h, --help                       Shows this help message
  -f, --force                      Overwrites existing directories
TXT

    output.should === expected
  end

  it('Show the help message using -h') do
    output   = `#{@bin_path} app -h`
    expected = <<TXT
Creates a new application prototype

Usage:
  zen app [NAME] [OPTIONS]

Example:
  zen app blog

Options:
  -h, --help                       Shows this help message
  -f, --force                      Overwrites existing directories
TXT

    output.should === expected
  end

  it('Create a new application prototype') do
    app_dir = '/tmp/zen'

    if File.directory?(app_dir)
      FileUtils.rm_rf(app_dir)
    end

    output  = `#{@bin_path} app #{app_dir} 2>&1`.strip

    output.should === "The application has been generated and saved in #{app_dir}"
    File.directory?(app_dir).should === true

    # Check various directories
    File.directory?(File.join(app_dir, 'config')).should                 === true
    File.directory?(File.join(app_dir, 'log')).should                    === true
    File.directory?(File.join(app_dir, 'log', 'database', 'dev')).should === true
    File.directory?(File.join(app_dir, 'public')).should                 === true

    # Check if the config files are correct
    config_generated = File.read(File.join(app_dir, 'config', 'config.rb'))
    config_proto     = File.read(__DIR__('../../../proto/app/config/config.rb'))

    config_generated.should === config_proto

    # Remove the application directory
    FileUtils.rm_rf(app_dir)
  end

  it('Create a new application using -f') do
    app_dir = '/tmp/zen'

    if File.directory?(app_dir)
      FileUtils.rm_rf(app_dir)
    end

    output        = `#{@bin_path} app #{app_dir} 2>&1`.strip
    output.should === "The application has been generated and saved in #{app_dir}"

    output        = `#{@bin_path} app #{app_dir} -f 2>&1`.strip
    output.should === "The application has been generated and saved in #{app_dir}"

    FileUtils.rm_rf(app_dir)
  end

end
