require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('custom_field_groups')

describe(
  "CustomFields::Controllers::CustomFieldGroups", 
  :type       => :acceptance, 
  :auto_login => true
) do

  it("No custom field groups should exist") do
    index_url = CustomFields::Controllers::CustomFieldGroups.r(:index).to_s
    message   = lang('custom_field_groups.messages.no_groups')

    visit(index_url)

    current_path.should == index_url
    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Create a new group") do
    index_url   = CustomFields::Controllers::CustomFieldGroups.r(:index).to_s
    new_url     = CustomFields::Controllers::CustomFieldGroups.r(:new).to_s
    edit_url    = CustomFields::Controllers::CustomFieldGroups.r(:edit).to_s
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

    current_path.should                                    =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should           === 'Spec field group'
    page.find('textarea[name="description"]').value.should === 'Spec field group desc'
  end

  it("Edit an existing group") do
    index_url   = CustomFields::Controllers::CustomFieldGroups.r(:index).to_s
    edit_url    = CustomFields::Controllers::CustomFieldGroups.r(:edit).to_s
    save_button = lang('custom_field_groups.buttons.save')

    visit(index_url)
    click_link('Spec field group')

    current_path.should                                    =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should           === 'Spec field group'
    page.find('textarea[name="description"]').value.should === 'Spec field group desc'

    # Update the details
    within('#custom_field_group_form') do
      fill_in('name', :with => 'Spec field group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec field group modified'
  end

  it("Delete an existing group") do
    index_url     = CustomFields::Controllers::CustomFieldGroups.r(:index).to_s
    delete_button = lang('custom_field_groups.buttons.delete')
    message       = lang('custom_field_groups.messages.no_groups')

    visit(index_url)
    check('custom_field_group_ids[]')

    click_on(delete_button)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

end
