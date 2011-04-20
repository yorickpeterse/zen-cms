require File.expand_path('../../../../../helper', __FILE__)

describe("Settings::Plugin::Settings") do
  include ::Settings::Model

  it("Register a settings group") do
    Zen::Plugin.call('com.zen.plugin.settings', :register_group) do |group|
      group.name  = 'general_spec'
      group.title = 'General Spec'
    end
  end

  it("Register two settings") do
    Zen::Plugin.call('com.zen.plugin.settings', :register) do |setting|
      setting.name        = 'spec'
      setting.title       = 'Spec'
      setting.group       = 'general_spec'
      setting.type        = 'select'
      setting.values      = [1,2,3]
      setting.description = 'An example of a setting with a select box.'
    end

    Zen::Plugin.call('com.zen.plugin.settings', :register) do |setting|
      setting.name  = 'spec_textbox'
      setting.title = 'Spec Textbox'
      setting.group = 'general_spec'
      setting.type  = 'textbox'
    end
  end

  it("Retrieve a setting") do
    setting = Zen::Plugin.call('com.zen.plugin.settings', :get, 'spec')

    setting.title.should       === 'Spec'
    setting.group.should       === 'general_spec'
    setting.values.should      === [1,2,3]
    setting.description.should === 'An example of a setting with a select box.'
  end

  it("Migrate all settings") do
    Zen::Plugin.call('com.zen.plugin.settings', :migrate)

    setting  = Setting[:name => 'spec']
    setting1 = Setting[:name => 'spec_textbox']

    setting.type.should  === 'select'
    setting1.type.should === 'textbox'
  end

  it("Remove all settings") do
    Zen::Plugin.call('com.zen.plugin.settings', :remove, ['spec', 'spec_textbox'])

    Setting[:name => 'spec'].should         === nil
    Setting[:name => 'spec_textbox'].should === nil
  end

end
