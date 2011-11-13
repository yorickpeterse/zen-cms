require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package', 'settings', 'controller', 'settings')

describe("Settings::Controller::Settings") do
  behaves_like :capybara

  index_url   = Settings::Controller::Settings.r(:index).to_s
  save_button = lang('settings.buttons.save')

  should('submit a form without a CSRF token') do
    response = page.driver.post(
      Settings::Controller::Settings.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  should('update a set of settings') do
    visit(index_url)

    within('#setting_form') do
      fill_in('website_name', :with => 'Zen spec')

      click_on(save_button)
    end

    page.find('input[name="website_name"]').value.should == 'Zen spec'

    within('#setting_form') do
      fill_in('website_name', :with => 'Zen')
      click_on(save_button)
    end

    page.find('input[name="website_name"]').value.should == 'Zen'
  end

  should('update a setting using checkboxes') do
    visit(index_url)

    page.has_selector?('input[type="checkbox"]').should                 == true
    page.has_selector?('input[type="checkbox"][value="value"]').should  == true
    page.has_selector?('input[type="checkbox"][value="value1"]').should == true

    within('#setting_form') do
      check('form_checkbox_0')
      check('form_checkbox_1')
      click_on(save_button)
    end

    page.find('input[id="form_checkbox_0"]').checked?.should == 'checked'
    page.find('input[id="form_checkbox_1"]').checked?.should == 'checked'

    value = get_setting(:checkbox).value

    value.is_a?(Array).should       == true
    value.include?('value').should  == true
    value.include?('value1').should == true
  end

  should('update a setting using a select box with multiple values') do
    visit(index_url)

    page.has_selector?('select[multiple="multiple"]').should == true
    page.has_selector?('option[value="value"]').should       == true
    page.has_selector?('option[value="value1"]').should      == true

    within('#setting_form') do
      select('Label', :from => 'form_select_multiple')
      select('Label 1', :from => 'form_select_multiple')
      click_on(save_button)
    end

    page.find('option[value="value"]').selected?.should  == 'selected'
    page.find('option[value="value1"]').selected?.should == 'selected'

    value = get_setting(:select_multiple).value

    value.include?('value').should  == true
    value.include?('value1').should == true
  end

  should('call the event after_edit_setting') do
    event_name = nil

    Zen::Event.listen(:after_edit_setting) do |setting|
      event_name = setting.value if setting.name == :website_name
    end

    visit(index_url)

    within('#setting_form') do
      click_on(save_button)
    end

    page.find('input[name="website_name"]').value.should == 'Zen'
    event_name.should                                    == 'Zen'

    Zen::Event.delete(:after_edit_setting)
  end
end
