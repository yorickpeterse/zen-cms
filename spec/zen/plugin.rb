require File.expand_path('../../helper', __FILE__)
require 'rdiscount'

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
      plugin.actions    = {
        :upcase => lambda do |string|
          string.upcase
        end
      }
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

  it("Extend the plugin's features") do
    plugin = Zen::Plugin['com.zen.plugin.spec']

    plugin.actions[:downcase] = lambda do |string|
      string.downcase
    end

    response = Zen::Plugin.call('com.zen.plugin.spec', :downcase, 'HELLO WORLD')
    
    response.should === 'hello world'
  end

end
