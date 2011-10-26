require File.expand_path('../../../../../helper', __FILE__)

describe("Settings::Controller::Settings") do
  behaves_like :capybara

  index_url   = Settings::Controller::Settings.r(:index).to_s
  save_button = lang('settings.buttons.save')

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Settings::Controller::Settings.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it("Update a set of settings") do
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

  it('Call the event after_edit_setting') do
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
