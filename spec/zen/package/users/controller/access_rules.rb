require File.expand_path('../../../../../helper', __FILE__)

describe("Users::Controller::AccessRules") do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Users::Controller::AccessRules.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No access rules should exist") do
    index_url = Users::Controller::AccessRules.r(:index).to_s
    message   = lang('access_rules.messages.no_rules')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new access rule") do
    index_url   = Users::Controller::AccessRules.r(:index).to_s
    new_button  = lang('access_rules.buttons.new')
    save_button = lang('access_rules.buttons.save')

    visit(index_url)
    click_link(new_button)

    within('#access_rule_form') do
      choose('form_rule_applies_0')
      select('Spec'    , :from => 'user_id')
      select('sections', :from => 'package')
      choose('form_create_access_1')
      choose('form_read_access_0')
      choose('form_update_access_1')
      choose('form_delete_access_1')
      click_on(save_button)
    end

    page.find('#form_rule_applies_0').checked?.should === 'checked'
    page.find('select[name="package"]').value.should  === 'sections'
  end

  it("Edit an existing access rule") do
    index_url   = Users::Controller::AccessRules.r(:index).to_s
    edit_url    = Users::Controller::AccessRules.r(:edit).to_s
    save_button = lang('access_rules.buttons.save')

    visit(index_url)
    click_link(lang('access_rules.labels.all_controllers'))

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#access_rule_form') do
      choose('form_rule_applies_1')
      click_on(save_button)
    end

    page.find('#form_rule_applies_1').checked?.should === 'checked'
  end

  it('Delete an access rule without specifying an ID') do
    index_url     = Users::Controller::AccessRules.r(:index).to_s
    delete_button = lang('access_rules.buttons.delete')
    message       = lang('access_rules.messages.no_rules')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="access_rule_ids[]"]').should === true
  end

  it("Delete an existing access rule") do
    index_url     = Users::Controller::AccessRules.r(:index).to_s
    delete_button = lang('access_rules.buttons.delete')
    message       = lang('access_rules.messages.no_rules')

    visit(index_url)
    check('access_rule_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

end
