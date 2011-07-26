require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFieldGroups') do
  behaves_like :capybara

  # Verifies if no custom field groups exist. This shouldn't be the case if all
  # specs handle their data correctly.
  it("No custom field groups should exist") do
    index_url = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    message   = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    current_path.should === index_url

    # If the page shows the message telling the user that there are no groups.
    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  # Creates a new field group and validates the results.
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

  # Edits the field group that was created in the spec above.
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

  it("Delete an existing group") do
    index_url     = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
    delete_button = lang('custom_field_groups.buttons.delete')
    message       = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    # Check all the radio buttons and submit the form
    check('custom_field_group_ids[]')
    click_on(delete_button)

    # Once all the groups have been removed the user is redirected back to the
    # overview. In this case no groups should exist anymore.
    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end
end # describe
