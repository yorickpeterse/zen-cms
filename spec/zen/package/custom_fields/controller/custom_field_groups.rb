require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFieldGroups') do
  behaves_like :capybara

  index_url     = CustomFields::Controller::CustomFieldGroups.r(:index).to_s
  new_url       = CustomFields::Controller::CustomFieldGroups.r(:new).to_s
  edit_url      = CustomFields::Controller::CustomFieldGroups.r(:edit).to_s
  save_button   = lang('custom_field_groups.buttons.save')
  delete_button = lang('custom_field_groups.buttons.delete')
  new_button    = lang('custom_field_groups.buttons.new')

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      CustomFields::Controller::CustomFieldGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it('Find no existing field groups') do
    message = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    current_path.should == index_url

    # If the page shows the message telling the user that there are no groups.
    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  it('Create a new group') do
    visit(index_url)
    click_link(new_button)

    current_path.should == new_url

    within('#custom_field_group_form') do
      fill_in('name'       , :with => 'Spec field group')
      fill_in('description', :with => 'Spec field group desc')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/

    page.find('input[name="name"]').value.should == 'Spec field group'

    page.find('textarea[name="description"]') \
      .value.should == 'Spec field group desc'
  end

  it('Search for a custom field group') do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within('#search_form') do
      fill_in('query', :with => 'Spec field group')
      click_on(search_button)
    end

    page.has_content?(error).should              == false
    page.has_content?('Spec field group').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should              == false
    page.has_content?('Spec field group').should == false
  end

  it("Edit an existing group") do
    visit(index_url)
    click_link('Spec field group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the details
    within('#custom_field_group_form') do
      fill_in('name', :with => 'Spec field group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Spec field group modified'
  end

  it("Fail to edit an existing group with invalid data") do
    visit(index_url)
    click_link('Spec field group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the details
    within('#custom_field_group_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  it("Fail to delete a group without an ID") do
    message = lang('custom_field_groups.messages.no_groups')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="custom_field_group_ids[]"]') .should == true
  end

  it("Delete an existing group") do
    message = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    check('custom_field_group_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  it('Call the event new_custom_field_group (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_new_custom_field_group) do |group|
      group.name += ' with event'
    end

    Zen::Event.listen(:after_new_custom_field_group) do |group|
      event_name = group.name
    end

    visit(index_url)
    click_on(new_button)

    within('#custom_field_group_form') do
      fill_in('name', :with => 'Field group')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Field group with event'
    event_name.should                            == 'Field group with event'

    Zen::Event.delete(
      :before_new_custom_field_group,
      :after_new_custom_field_group
    )
  end

  it('Call the event edit_custom_field_group (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_edit_custom_field_group) do |group|
      group.name = 'Field group modified'
    end

    Zen::Event.listen(:after_edit_custom_field_group) do |group|
      event_name = group.name
    end

    visit(index_url)
    click_on('Field group with event')

    within('#custom_field_group_form') do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Field group modified'
    event_name.should                            == 'Field group modified'

    Zen::Event.delete(
      :before_edit_custom_field_group,
      :after_edit_custom_field_group
    )
  end

  it('Call the event delete_custom_field_group (before and after)') do
    event_name  = nil
    event_name2 = nil
    message     = lang('custom_field_groups.messages.no_groups')

    Zen::Event.listen(:before_delete_custom_field_group) do |group|
      event_name = group.name
    end

    Zen::Event.listen(:after_delete_custom_field_group) do |group|
      event_name2 = group.name
    end

    visit(index_url)
    check('custom_field_group_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
    event_name.should                           == 'Field group modified'
    event_name2.should                          == event_name

    Zen::Event.delete(
      :before_delete_custom_field_group,
      :after_delete_custom_field_group
    )
  end
end # describe
