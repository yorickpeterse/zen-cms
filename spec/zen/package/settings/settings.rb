require File.expand_path('../../../../helper', __FILE__)
require File.join(Zen::Fixtures, 'package/settings/plugin/settings')

describe('Settings::Setting') do
  it("Retrieve a setting") do
    setting = get_setting('spec')

    setting.title.should       === 'Spec'
    setting.group.should       === :general_spec
    setting.values.should      === [1,2,3]
    setting.description.should === 'An example of a setting with a select box.'
  end

  it("Migrate all settings") do
    Settings::Setting.migrate

    setting  = Settings::Model::Setting[:name => 'spec']
    setting1 = Settings::Model::Setting[:name => 'spec_textbox']

    setting.type.should  === 'select'
    setting1.type.should === 'textbox'
  end

  it("Remove all settings") do
    Settings::Setting.remove(['spec', 'spec_textbox'])

    Settings::Model::Setting[:name => 'spec'].should         === nil
    Settings::Model::Setting[:name => 'spec_textbox'].should === nil
  end
end
