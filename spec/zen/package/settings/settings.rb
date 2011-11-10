require File.expand_path('../../../../helper', __FILE__)

describe('Settings::Setting') do
  should('register a settings group') do
    Settings::SettingsGroup.add do |group|
      group.name  = 'general_spec'
      group.title = 'General Spec'
    end

    Settings::SettingsGroup::REGISTERED.key?(:general_spec).should == true

    Settings::SettingsGroup::REGISTERED[:general_spec] \
      .title.should == 'General Spec'
  end

  should('register an already existing settings group') do
    should.raise?(Zen::ValidationError) do
      Settings::SettingsGroup.add do |group|
        group.name  = 'general_spec'
        group.title = 'General Spec'
      end
    end
  end

  should('register a setting with an invalid type') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name  = 'invalid'
        setting.title = setting.name
        setting.group = 'general_spec'
        setting.type  = 'invalid'
      end
    end
  end

  should('register a setting with an invalid group') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name  = 'invalid'
        setting.title = setting.name
        setting.group = 'invalid'
        setting.type  = 'textbox'
      end
    end
  end

  should('register two settings') do
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

  should('register an already existing setting') do
    should.raise?(Zen::ValidationError) do
      Settings::Setting.add do |setting|
        setting.name   = 'spec'
        setting.title  = 'Spec'
        setting.group  = 'general_spec'
        setting.type   = 'select'
      end
    end
  end

  should('retrieve a non existing setting') do
    should.raise?(ArgumentError) do
      get_setting('invalid')
    end
  end

  should('retrieve a setting') do
    setting = get_setting('spec')

    setting.title.should       == 'Spec'
    setting.group.should       == :general_spec
    setting.values.should      == [1,2,3]
    setting.description.should == 'An example of a setting with a select box.'
  end

  should('Migrate all settings') do
    Settings::Setting.migrate

    setting  = Settings::Model::Setting[:name => 'spec']
    setting1 = Settings::Model::Setting[:name => 'spec_textbox']

    setting.type.should  == 'select'
    setting1.type.should == 'textbox'
  end

  should('Update a setting') do
    Ramaze.setup_dependencies

    get_setting('spec').value = 'Setting value'

    Settings::Model::Setting[:name => 'spec'].value.should == 'Setting value'
    Ramaze::Cache.settings.fetch(:spec).should             == 'Setting value'
  end

  should('remove all settings') do
    Settings::Setting.remove('spec')
    Settings::Setting.remove(['spec_textbox'])

    Settings::Model::Setting[:name => 'spec'].should         == nil
    Settings::Model::Setting[:name => 'spec_textbox'].should == nil
  end
end
