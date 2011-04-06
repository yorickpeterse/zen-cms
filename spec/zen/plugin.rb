require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../resources/plugin/spec', __FILE__)
require 'rdiscount'

include ::Zen::Plugin
  
describe("Zen::Plugin") do
  
  it("No plugins should be added") do
    lambda { Zen::Plugin['com.foobar'] }.should raise_error(Zen::PluginError)
  end

  it("Add a new plugin") do
    Zen::Plugin.add do |plugin|
      plugin.name       = 'Spec'
      plugin.author     = 'Yorick Peterse'
      plugin.about      = 'A simple spec plugin'
      plugin.url        = 'http://zen-cms.com/'
      plugin.identifier = 'com.zen.plugin.spec'
      plugin.plugin     = SpecPlugin
    end

    Zen::Plugin.plugins.nil?.should                === false
    Zen::Plugin['com.zen.plugin.spec'].name.should === 'Spec'
  end

  it("Retrieve a plugin by it's identifier") do
    plugin = Zen::Plugin['com.zen.plugin.spec']

    plugin.name.should   === 'Spec'
    plugin.author.should === 'Yorick Peterse'
  end

  it("Execute a plugin") do
    response = Zen::Plugin.call('com.zen.plugin.spec', :upcase, 'hello world')

    response.should === 'HELLO WORLD'
  end

  it("Validate the type of a variable") do
    lambda { validate_type(10, :number, String) }.should raise_error(TypeError)
  end

end
