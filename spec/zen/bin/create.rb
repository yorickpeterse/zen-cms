require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../../lib/zen/bin/runner')
require 'fileutils'

describe('Zen::Bin::Create') do
  @bin_path = __DIR__('../../../bin/zen')

  it('Show the help message') do
    output = catch_output do
      Zen::Bin::Create.new.run
    end

    output[:stdout].include?(Zen::Bin::Create::Banner).should == true
  end

  it('Show the help message using -h') do
    output = catch_output do
      Zen::Bin::Create.new.run(['-h'])
    end

    output[:stdout].include?(Zen::Bin::Create::Banner).should == true
  end

  it('Create a new application prototype') do
    app_dir = '/tmp/zen'

    if File.directory?(app_dir)
      FileUtils.rm_rf(app_dir)
    end

    output = catch_output do
      Zen::Bin::Create.new.run([app_dir])
    end

    output[:stdout].strip \
      .should == "The application has been generated and saved in #{app_dir}"

    File.directory?(app_dir).should == true

    # Check various directories
    File.directory?(File.join(app_dir, 'config')).should                 == true
    File.directory?(File.join(app_dir, 'log')).should                    == true
    File.directory?(File.join(app_dir, 'log', 'database', 'dev')).should == true
    File.directory?(File.join(app_dir, 'public')).should                 == true

    # Check if the config files are correct
    config_generated = File.read(File.join(app_dir, 'config', 'config.rb'))
    config_proto     = File.read(__DIR__('../../../proto/app/config/config.rb'))

    config_generated.should == config_proto

    # Remove the application directory
    FileUtils.rm_rf(app_dir)
  end

  it('Create a new application using -f') do
    app_dir = '/tmp/zen'

    if File.directory?(app_dir)
      FileUtils.rm_rf(app_dir)
    end

    output = catch_output do
      Zen::Bin::Create.new.run([app_dir])
    end

    output[:stdout].strip \
      .should == "The application has been generated and saved in #{app_dir}"

    # Warn that it exists
    output = catch_output do
      Zen::Bin::Create.new.run([app_dir])
    end

    output[:stderr].strip.should \
      == "The application #{app_dir} already exists, use -f to overwrite it."

    # Force it
    output = catch_output do
      Zen::Bin::Create.new.run([app_dir, '-f'])
    end

    output[:stdout].strip \
      .should == "The application has been generated and saved in #{app_dir}"

    FileUtils.rm_rf(app_dir)
  end

end
