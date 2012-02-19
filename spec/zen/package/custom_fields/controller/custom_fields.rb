require File.expand_path('../../../../../helper', __FILE__)

describe 'CustomFields::Controller::CustomFields' do
  behaves_like :capybara

  group = CustomFields::Model::CustomFieldGroup.create(
    :name => 'Spec field group'
  )

  index_url     = CustomFields::Controller::CustomFields.r(:index, group.id).to_s
  edit_url      = CustomFields::Controller::CustomFields.r(:edit , group.id).to_s
  new_button    = lang('custom_fields.buttons.new')
  save_button   = lang('custom_fields.buttons.save')
  delete_button = lang('custom_fields.buttons.delete')

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      CustomFields::Controller::CustomFields.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Find no existing fields' do
    message = lang('custom_fields.messages.no_fields')

    visit(index_url)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  it "Create a new custom field" do
    type_select   = lang('custom_fields.special.type_hash.textbox')
    format_select = lang('zen_general.markup.markdown')
    textbox_field = CustomFields::Model::CustomFieldType[:name => 'textbox']

    visit(index_url)
    click_link(new_button)

    within '#custom_field_form' do
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
    page.find('input[name="name"]').value.should  == 'Spec field'

    page.find('select[name="custom_field_type_id"]') \
      .value.should == textbox_field.id.to_s

    page.find_field('form_description').value.should     == 'Spec description'
    page.find_field('form_possible_values').value.should == 'Yorick|yorick'
    page.find_field('form_textarea_rows').value.should   == '5'
    page.find_field('form_text_limit').value.should      == '10'
    page.find_field('form_sort_order').value.should      == '2'
  end

  it 'Search for a custom field' do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within '#search_form' do
      fill_in('query', :with => 'Spec field')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec field').should == true

    within '#search_form' do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec field').should == false
  end

  it "Edit an existing custom field" do
    type_select    = lang('custom_fields.special.type_hash.textarea')
    textarea_field = CustomFields::Model::CustomFieldType[:name => 'textarea']

    visit(index_url)
    click_link('Spec field')

    # Update the form
    within '#custom_field_form' do
      fill_in('form_name', :with => 'Spec field modified')

      # Change the field type to a textarea
      select(type_select, :from => 'form_custom_field_type_id')

      # Update the description and some of the settings
      fill_in('form_description', :with => 'Spec description updated')
      fill_in('form_text_limit' , :with => '15')

      click_on(save_button)
    end

    page.find('input[name="name"]').value.should    == 'Spec field modified'
    page.find_field('form_text_limit').value.should == '15'

    page.find_field('form_description') \
      .value.should == 'Spec description updated'

    page.find_field('form_custom_field_type_id') \
      .value.should == textarea_field.id.to_s
  end

  enable_javascript

  it 'Automatically save a custom field' do
    visit(index_url)
    click_link('Spec field modified')

    within '#custom_field_form' do
      fill_in('name', :with => 'Spec field autosave')
    end

    autosave_form('custom_field_form')

    visit(index_url)

    page.has_content?('Spec field autosave')
    click_link('Spec field autosave')

    within '#custom_field_form' do
      fill_in('name', :with => 'Spec field modified')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Spec field modified'
  end

  disable_javascript

  it "Edit an existing custom field with invalid data" do
    visit(index_url)
    click_link('Spec field')

    within '#custom_field_form' do
      fill_in('form_name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  it 'Fail to delete a field without an ID' do
    message = lang('custom_fields.messages.no_fields')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="custom_field_ids[]"]').should == true
  end

  it "Delete an existing custom field" do
    message = lang('custom_fields.messages.no_fields')

    visit(index_url)
    check('custom_field_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  it 'Call the event new_custom_field (before and after)' do
    event_name  = nil
    type_select = lang('custom_fields.special.type_hash.textarea')

    Zen::Event.listen(:before_new_custom_field) do |field|
      field.name += ' with event'
    end

    Zen::Event.listen(:after_new_custom_field) do |field|
      event_name = field.name
    end

    visit(index_url)
    click_on(new_button)

    within '#custom_field_form' do
      fill_in('form_name', :with => 'Custom field')
      select(type_select, :from => 'form_custom_field_type_id')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Custom field with event'
    event_name.should                            == 'Custom field with event'

    Zen::Event.delete(:before_new_custom_field, :after_new_custom_field)
  end

  it 'Call the event edit_custom_field (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_edit_custom_field) do |field|
      field.name = 'Custom field modified'
    end

    Zen::Event.listen(:after_edit_custom_field) do |field|
      event_name = field.name
    end

    visit(index_url)
    click_on('Custom field with event')

    within '#custom_field_form' do
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Custom field modified'
    event_name.should                            == 'Custom field modified'

    Zen::Event.delete(:before_edit_custom_field, :after_edit_custom_field)
  end

  it 'Call the event delete_custom_field (before and after)' do
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_delete_custom_field) do |field|
      event_name = field.name
    end

    Zen::Event.listen(:after_delete_custom_field) do |field|
      event_name2 = field.name
    end

    visit(index_url)
    check('custom_field_ids[]')
    click_on(delete_button)

    page.has_content?('Custom field modified').should == false
    event_name.should                                 == 'Custom field modified'
    event_name2.should                                == event_name

    Zen::Event.delete(:before_delete_custom_field, :after_delete_custom_field)
  end

  group.destroy
end # describe
