require File.expand_path('../../../../helper', __FILE__)

describe('Settings::Setting') do
  it('Register a settings group') do
    Settings::SettingsGroup.add do |group|
      group.name  = 'general_spec'
      group.title = 'General Spec'
    end

    Settings::SettingsGroup::REGISTERED.key?(:general_spec).should == true

    Settings::SettingsGroup::REGISTERED[:general_spec] \
      .title.should == 'General Spec'
  end

  it('Register an already existing settings group') do
    should.raise?(Zen::ValidationError) do
      Settings::SettingsGroup.add do |group|
        group.name  = 'general_spec'
        group.title = 'General Spec'
      end
    end
  end

  it('Register a setting with an invalid type') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name  = 'invalid'
        setting.title = setting.name
        setting.group = 'general_spec'
        setting.type  = 'invalid'
      end
    end
  end

  it('Register a setting with an invalid group') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name  = 'invalid'
        setting.title = setting.name
        setting.group = 'invalid'
        setting.type  = 'textbox'
      end
    end
  end

  it('Register two settings') do
    Settings::Setting.add do |setting|
      setting.name        = 'spec'
      setting.title       = 'Spec'
      setting.group       = 'general_spec'
      setting.type        = 'select'
      setting.values      = [1,2,3]
      setting.description = 'An example of a setting with a select box.'
    end

    Settings::Setting.add do |setting|
      setting.name  = 'spec_textbox'
      setting.title = 'Spec Textbox'
      setting.group = 'general_spec'
      setting.type  = 'textbox'
    end

    Settings::Setting::REGISTERED.key?(:spec).should         == true
    Settings::Setting::REGISTERED.key?(:spec_textbox).should == true
  end

  it('Register an already existing setting') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name   = 'spec'
        setting.title  = 'Spec'
        setting.group  = 'general_spec'
        setting.type   = 'select'
      end
    end
  end

  it('Retrieve a non existing setting') do
    should.raise?(ArgumentError) do
      get_setting('invalid')
    end
  end

  it('Retrieve a setting') do
    setting = get_setting('spec')

    setting.title.should       == 'Spec'
    setting.group.should       == :general_spec
    setting.values.should      == [1,2,3]
    setting.description.should == 'An example of a setting with a select box.'
  end

  it('Migrate all settings') do
    Settings::Setting.migrate

    Settings::Model::Setting[:name => 'spec'].nil?.should         == false
    Settings::Model::Setting[:name => 'spec_textbox'].nil?.should == false
  end

  it('Update a setting') do
    Ramaze.setup_dependencies

    get_setting(:spec).value = 'Setting value'

    get_setting(:spec).value.should == 'Setting value'

    Settings::Model::Setting[:name => 'spec'].value.should \
      == Ramaze::Cache.settings.fetch(:spec)
  end

  it('Remove all settings') do
    Settings::Setting.remove('spec')
    Settings::Setting.remove(['spec_textbox'])

    Settings::Model::Setting[:name => 'spec'].should         == nil
    Settings::Model::Setting[:name => 'spec_textbox'].should == nil
  end
end
