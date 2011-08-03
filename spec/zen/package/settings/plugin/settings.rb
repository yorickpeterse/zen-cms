require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::Fixtures, 'package/settings/plugin/settings')

describe("Settings::Plugin::Settings") do
  extend ::Settings::Model

  it("Retrieve a setting") do
    setting = plugin(:settings, :get, 'spec')

    setting.title.should       === 'Spec'
    setting.group.should       === 'general_spec'
    setting.values.should      === [1,2,3]
    setting.description.should === 'An example of a setting with a select box.'
  end

  it("Migrate all settings") do
    plugin(:settings, :migrate)

    setting  = Setting[:name => 'spec']
    setting1 = Setting[:name => 'spec_textbox']

    setting.type.should  === 'select'
    setting1.type.should === 'textbox'
  end

  it("Remove all settings") do
    plugin(:settings, :remove, ['spec', 'spec_textbox'])

    Setting[:name => 'spec'].should         === nil
    Setting[:name => 'spec_textbox'].should === nil
  end

end
