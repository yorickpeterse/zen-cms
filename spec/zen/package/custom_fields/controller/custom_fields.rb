require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFields') do
  behaves_like :capybara

  @group = CustomFields::Model::CustomFieldGroup.create(
    :name => 'Spec field group'
  )

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      CustomFields::Controller::CustomFields.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No custom fields should exist") do
    index_url = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s
    message   = lang('custom_fields.messages.no_fields')

    visit(index_url)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Create a new custom field") do
    index_url = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s
    edit_url  = CustomFields::Controller::CustomFields.r(:edit , @group.id).to_s

    new_button    = lang('custom_fields.buttons.new')
    save_button   = lang('custom_fields.buttons.save')
    type_select   = lang('custom_fields.special.type_hash.textbox')
    format_select = lang('zen_general.special.format_hash.markdown')
    textbox_field = CustomFields::Model::CustomFieldType[:name => 'textbox']

    visit(index_url)
    click_link(new_button)

    within('#custom_field_form') do
      fill_in('form_name', :with => 'Spec field')

      # Set the type to a textbox
      select(type_select, :from => 'form_custom_field_type_id')

      # Set the format to Markdown
      select(format_select, :from => 'form_format')

      fill_in('form_description'    , :with => 'Spec description')
      fill_in('form_possible_values', :with => "Yorick|yorick")

      # Set some of the settings
      fill_in('form_textarea_rows', :with => '5')
      fill_in('form_text_limit'   , :with => '10')
      fill_in('form_sort_order'   , :with => '2')

      click_on(save_button)
    end

    current_path.should                           =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should  === 'Spec field'

    page.find('select[name="custom_field_type_id"]') \
      .value.should === textbox_field.id.to_s

    page.find_field('form_description').value.should     === 'Spec description'
    page.find_field('form_possible_values').value.should === 'Yorick|yorick'
    page.find_field('form_textarea_rows').value.should   === '5'
    page.find_field('form_text_limit').value.should      === '10'
    page.find_field('form_sort_order').value.should      === '2'
  end

  it("Edit an existing custom field") do
    index_url   = CustomFields::Controller::CustomFields \
      .r(:index, @group.id).to_s

    save_button    = lang('custom_fields.buttons.save')
    type_select    = lang('custom_fields.special.type_hash.textarea')
    textarea_field = CustomFields::Model::CustomFieldType[:name => 'textarea']

    visit(index_url)
    click_link('Spec field')

    # Update the form
    within('#custom_field_form') do
      fill_in('form_name', :with => 'Spec field modified')

      # Change the field type to a textarea
      select(type_select, :from => 'form_custom_field_type_id')

      # Update the description and some of the settings
      fill_in('form_description', :with => 'Spec description updated')
      fill_in('form_text_limit' , :with => '15')

      click_on(save_button)
    end

    page.find('input[name="name"]').value.should    === 'Spec field modified'
    page.find_field('form_text_limit').value.should === '15'

    page.find_field('form_description') \
      .value.should === 'Spec description updated'

    page.find_field('form_custom_field_type_id') \
      .value.should === textarea_field.id.to_s
  end

  it("Edit an existing custom field with invalid data") do
    index_url   = CustomFields::Controller::CustomFields \
      .r(:index, @group.id).to_s

    save_button = lang('custom_fields.buttons.save')

    visit(index_url)
    click_link('Spec field')

    within('#custom_field_form') do
      fill_in('form_name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should === true
  end

  it('Try to delete a field with no IDs specified') do
    group_id      = @group.id
    index_url     = CustomFields::Controller::CustomFields \
      .r(:index, group_id).to_s

    delete_button = lang('custom_fields.buttons.delete')
    message       = lang('custom_fields.messages.no_fields')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="custom_field_ids[]"]').should === true
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

  @group.destroy
end # describe
