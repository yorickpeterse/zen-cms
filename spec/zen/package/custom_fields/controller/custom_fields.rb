require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('custom_fields')
Zen::Language.load('custom_field_groups')

describe('CustomFields::Controller::CustomFields') do
  behaves_like :capybara

  it("Create the test data") do
    @group = CustomFields::Model::CustomFieldGroup.create(
      :name => 'Spec field group' 
    )

    @group.name.should === 'Spec field group'
  end

  it("No custom fields should exist") do
    group_id  = @group.id
    index_url = CustomFields::Controller::CustomFields.r(:index,  group_id).to_s
    message   = lang('custom_fields.messages.no_fields')

    visit(index_url)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Create a new custom field") do
    group_id      = @group.id
    index_url     = CustomFields::Controller::CustomFields \
      .r(:index, group_id).to_s
 
    edit_url      = CustomFields::Controller::CustomFields \
      .r(:edit , group_id).to_s
    
    new_button    = lang('custom_fields.buttons.new')
    save_button   = lang('custom_fields.buttons.save')
    type_select   = lang('custom_fields.special.type_hash.textbox')
    format_select = lang('zen_general.special.format_hash.markdown')

    visit(index_url)
    click_link(new_button)

    within('#custom_field_form') do
      fill_in('form_name' , :with => 'Spec field')
      select(type_select  , :from => 'form_type')
      select(format_select, :from => 'form_format')
      click_on(save_button)
    end

    current_path.should                           =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should  === 'Spec field'
    page.find('select[name="type"]').value.should === 'textbox'
  end

  it("Edit an existing custom field") do
    group_id    = @group.id
    index_url   = CustomFields::Controller::CustomFields \
      .r(:index, group_id).to_s
    
    save_button = lang('custom_fields.buttons.save')

    visit(index_url)
    click_link('Spec field')

    within('#custom_field_form') do
      fill_in('form_name', :with => 'Spec field modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec field modified'
  end

  it("Delete an existing custom field") do
    group_id      = @group.id
    index_url     = CustomFields::Controller::CustomFields \
      .r(:index, group_id).to_s
    
    delete_button = lang('custom_fields.buttons.delete')
    message       = lang('custom_fields.messages.no_fields')

    visit(index_url)
    check('custom_field_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Delete all the test data") do
    @group.destroy

    CustomFields::Model::CustomFieldGroup[:name => 'Spec field group'] \
      .should === nil
  end

end
