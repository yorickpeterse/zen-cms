require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFieldGroups') do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      CustomFields::Controller::CustomFieldGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No custom field groups should exist") do
    index_url = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    message   = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    current_path.should === index_url

    # If the page shows the message telling the user that there are no groups.
    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Create a new group") do
    index_url   = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    new_url     = CustomFields::Controller::CustomFieldGroups.r(:new).to_s
    edit_url    = CustomFields::Controller::CustomFieldGroups.r(:edit).to_s
    add_button  = lang('custom_field_groups.buttons.new')
    save_button = lang('custom_field_groups.buttons.save')

    visit(index_url)
    click_link(add_button)

    current_path.should == new_url

    within('#custom_field_group_form') do
      fill_in('name'       , :with => 'Spec field group')
      fill_in('description', :with => 'Spec field group desc')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/

    page.find('input[name="name"]') \
      .value.should === 'Spec field group'

    page.find('textarea[name="description"]') \
      .value.should === 'Spec field group desc'
  end

  it("Edit an existing group") do
    index_url   = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    edit_url    = CustomFields::Controller::CustomFieldGroups.r(:edit).to_s
    save_button = lang('custom_field_groups.buttons.save')

    visit(index_url)
    click_link('Spec field group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the details
    within('#custom_field_group_form') do
      fill_in('name', :with => 'Spec field group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]') \
      .value.should === 'Spec field group modified'
  end

  it("Edit an existing group with invalid data") do
    index_url   = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    edit_url    = CustomFields::Controller::CustomFieldGroups.r(:edit).to_s
    save_button = lang('custom_field_groups.buttons.save')

    visit(index_url)
    click_link('Spec field group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the details
    within('#custom_field_group_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should === true
  end

  it("Try to delete a group without an ID specified") do
    index_url     = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    delete_button = lang('custom_field_groups.buttons.delete')
    message       = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    click_on(delete_button)

    page.has_selector?('input[name="custom_field_group_ids[]"]') \
      .should === true
  end

  it("Delete an existing group") do
    index_url     = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    delete_button = lang('custom_field_groups.buttons.delete')
    message       = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    check('custom_field_group_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end
end # describe
