require File.expand_path('../../helper', __FILE__)
require 'rdiscount'

fixtures ['plugin']

describe("Zen::Plugin") do
  
  it("No plugins should be added") do
    should.raise?(Zen::PluginError) { Zen::Plugin[:foobar] }
  end

  it("Add a new plugin") do
    Zen::Plugin.add do |plugin|
      plugin.name    = 'spec'
      plugin.author  = 'Yorick Peterse'
      plugin.about   = 'A simple spec plugin'
      plugin.url     = 'http://zen-cms.com/'
      plugin.plugin  = SpecPlugin
    end

    Zen::Plugin::Registered.empty?.should  === false
    Zen::Plugin[:spec].name.should         === :spec
  end

  it("Retrieve a plugin by it's name") do
    plugin = Zen::Plugin[:spec]

    plugin.name.should   === :spec
    plugin.author.should === 'Yorick Peterse'
  end

  it("Execute a plugin") do
    response = plugin(:spec, :upcase, 'hello world')

    response.should === 'HELLO WORLD'
  end

end
