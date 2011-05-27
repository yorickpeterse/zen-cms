require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('settings')

describe("Settings::Controller::Settings", :type => :acceptance, :auto_login => true) do

  it("Update a set of settings") do
    index_url   = Settings::Controller::Settings.r(:index).to_s
    save_button = lang('settings.buttons.save')

    visit(index_url)

    within('#setting_form') do
      fill_in('website_name', :with => 'Zen spec')
      choose('form_website_enabled_0')

      click_on(save_button)
    end

    page.find('input[name="website_name"]').value.should         === 'Zen spec'
    page.find('input[id="form_website_enabled_0"]').value.should === '1'

    within('#setting_form') do
      fill_in('website_name', :with => 'Zen')
      choose('form_website_enabled_1')
    end

    page.find('input[name="website_name"]').value.should         === 'Zen'
    page.find('input[id="form_website_enabled_1"]').value.should === '0'
  end

end
