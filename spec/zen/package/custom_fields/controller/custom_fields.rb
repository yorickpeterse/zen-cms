require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFields') do
  behaves_like :capybara

  # Creates the test data that's needed for this specification and validates it
  # to ensure it's correct.
  it("Create the test data") do
    @group = CustomFields::Model::CustomFieldGroup.create(
      :name => 'Spec field group'
    )

    @group.name.should    === 'Spec field group'
    @group.id.nil?.should === false

    # Check if the record is actually there
    CustomFields::Model::CustomFieldGroup[:name => 'Spec field group'] \
      .nil?.should === false
  end

  # Navigates to the overview of all the custom fields of a particular group and
  # checks if there are no fields.
  it("No custom fields should exist") do
    index_url = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s
    message   = lang('custom_fields.messages.no_fields')

    visit(index_url)

    # When no fields are available a message is displayed and the table with all
    # records isn't.
    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  # Navigates to the index page of a certain custom field group, clicks the link
  # to the form for a new field and submits it.
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

  # Similar to the spec above this method navigates to the index page but
  # instead of creating a new field it will instead edit an existing one.
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

  # Deletes the custom field that was created and modified in the specs above.
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

  # Removes all the test data, in this case the custom field group that was
  # created earlier in this specification.
  it("Delete all the test data") do
    @group.destroy

    CustomFields::Model::CustomFieldGroup[:name => 'Spec field group'] \
      .should === nil
  end
end # describe
