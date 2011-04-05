require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('access_rules')

describe("Users::Controller::AccessRules", :type => :acceptance, :auto_login => true) do
  include Users::Controller

  it("No access rules should exist") do
    index_url = AccessRules.r(:index).to_s
    message   = lang('access_rules.messages.no_rules')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new access rule") do
    index_url   = AccessRules.r(:index).to_s
    new_button  = lang('access_rules.buttons.new')
    save_button = lang('access_rules.buttons.save')

    visit(index_url)
    click_link(new_button)

    within('#access_rule_form') do
      choose('form_rule_applies_0')
      select('Spec'    , :from => 'user_id')
      select('Sections', :from => 'extension')
      choose('form_create_access_1')
      choose('form_read_access_0')
      choose('form_update_access_1')
      choose('form_delete_access_1')
      click_on(save_button)
    end

    page.find('#form_rule_applies_0').checked?.should  === 'checked'
    page.find('select[name="extension"]').value.should === 'com.zen.sections'
  end

  it("Edit an existing access rule") do
    index_url   = AccessRules.r(:index).to_s
    edit_url    = AccessRules.r(:edit).to_s
    save_button = lang('access_rules.buttons.save')

    visit(index_url)
    click_link('com.zen.sections')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#access_rule_form') do
      choose('form_rule_applies_1')
      click_on(save_button) 
    end

    page.find('#form_rule_applies_1').checked?.should  === 'checked'
  end

  it("Delete an existing access rule") do
    index_url     = AccessRules.r(:index).to_s
    delete_button = lang('access_rules.buttons.delete')
    message       = lang('access_rules.messages.no_rules')

    visit(index_url)
    check('access_rule_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

end
