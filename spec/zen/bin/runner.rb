require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../../lib/zen/bin/runner')

describe('Zen::Bin::Runner') do

  it('Show the help message') do
    output = catch_output do
      Zen::Bin::Runner.run
    end

    output[:stdout].include?(Zen::Bin::Runner::Banner).should == true
  end

  it('Show the help message using -h') do
    output = catch_output do
      Zen::Bin::Runner.run(['-h'])
    end

    output[:stdout].include?(Zen::Bin::Runner::Banner).should == true
  end

  it('Show the version number') do
    output = catch_output do
      Zen::Bin::Runner.run(['-v'])
    end

    output[:stdout].strip.should == Zen::Version
  end

  it('Run a command') do
    output = catch_output do
      Zen::Bin::Runner.run(['create'])
    end

    output[:stdout].strip.include?(Zen::Bin::Create::Banner).should == true
  end

  it('Run a command') do
    output = catch_output do
      Zen::Bin::Runner.run(['invalid'])
    end

    output[:stdout].empty?.should == true
    output[:stderr].strip.should  == 'The specified command is invalid'
  end

end
