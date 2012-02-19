require File.expand_path('../../../../../helper', __FILE__)

describe 'CustomFields::Controller::CustomFieldTypes' do
  behaves_like :capybara

  index_url     = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
  new_url       = CustomFields::Controller::CustomFieldTypes.r(:new).to_s
  edit_url      = CustomFields::Controller::CustomFieldTypes.r(:edit).to_s
  new_button    = lang('custom_field_types.buttons.new')
  save_button   = lang('custom_field_types.buttons.save')
  delete_button = lang('custom_field_types.buttons.delete')

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      CustomFields::Controller::CustomFieldTypes.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Find a number of field types' do
    message = lang('custom_field_types.messages.no_field_types')
    rows    = CustomFields::Model::CustomFieldType.count

    visit(index_url)

    current_path.should                          == index_url
    page.has_content?(message).should            == false
    page.has_selector?('table tbody tr').should  == true
    page.all('table tbody tr').count.should      == rows
  end

  it 'Create a new custom field type' do
    method_id = CustomFields::Model::CustomFieldMethod[
      :name => 'input_text'
    ].id.to_s

    visit(index_url)
    click_link(new_button)

    current_path.should == new_url

    # Submit the form
    within '#custom_field_type_form' do
      # Fill in various text fields
      fill_in('form_name', :with => 'Spec type')

      fill_in(
        'form_language_string',
        :with => 'custom_fields.special.type_hash.textbox'
      )

      fill_in('form_html_class', :with => 'spec_class')

      # Choose "Yes" for the serialize and allow_markup options
      choose('form_serialize_0')
      choose('form_allow_markup_0')

      select('input_text', :from => 'form_custom_field_method_id')

      click_on(save_button)
    end

    # Validate the results
    current_path.should =~ /#{edit_url}\/\d+/

    page.find_field('form_name').value.should == 'Spec type'

    page.find_field('form_language_string') \
      .value.should == 'custom_fields.special.type_hash.textbox'

    page.find_field('form_html_class').value.should      == 'spec_class'
    page.find_field('form_serialize_0').checked?.should == 'checked'

    page.find_field('form_allow_markup_0').checked?.should      == 'checked'
    page.find_field('form_custom_field_method_id').value.should == method_id
  end

  it 'Search for a custom field type' do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within '#search_form' do
      fill_in('query', :with => 'Spec type')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec type').should == true

    within '#search_form' do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should       == false
    page.has_content?('Spec type').should == false
  end

  it 'Edit a custom field type' do
    method_id = CustomFields::Model::CustomFieldMethod[
      :name => 'textarea'
    ].id.to_s

    visit(index_url)
    click_link('Spec type')

    current_path.should =~ /#{edit_url}\/\d+/

    # Update the form
    within '#custom_field_type_form' do
      fill_in('form_name', :with => 'Spec type modified')

      fill_in(
        'form_language_string',
        :with => 'custom_fields.special.type_hash.textarea'
      )

      fill_in('form_html_class', :with => 'spec_class_modified')
      select('textarea'        , :from => 'custom_field_method_id')

      click_on(save_button)
    end

    # Validate the results
    current_path.should =~ /#{edit_url}\/\d+/

    page.find_field('form_name').value.should      == 'Spec type modified'
    page.find_field('form_html_class').value.should == 'spec_class_modified'

    page.find_field('form_language_string') \
      .value.should == 'custom_fields.special.type_hash.textarea'

    page.find_field('custom_field_method_id').value.should == method_id
  end

  enable_javascript

  it 'Automatically save a custom field type' do
    visit(index_url)
    click_link('Spec type modified')

    within '#custom_field_type_form' do
      fill_in('name', :with => 'Spec type autosave')
    end

    autosave_form('custom_field_type_form')

    visit(index_url)

    page.has_content?('Spec type autosave').should == true
    click_link('Spec type autosave')

    within '#custom_field_type_form' do
      fill_in('name', :with => 'Spec type modified')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Spec type modified'
  end

  disable_javascript

  it 'Edit a custom field type with invalid data' do
    visit(index_url)
    click_link('Spec type')

    current_path.should =~ /#{edit_url}\/\d+/

    within '#custom_field_type_form' do
      fill_in('form_name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  it 'Fail to delete a field type without an ID' do
    type_id = CustomFields::Model::CustomFieldType[
      :name => 'Spec type modified'
    ].id

    visit(index_url)
    click_on(delete_button)

    page.has_selector?("input[id=\"custom_field_type_#{type_id}\"]") \
      .should == true
  end

  it 'Delete a custom field type' do
    rows    = CustomFields::Model::CustomFieldType.count - 1
    type_id = CustomFields::Model::CustomFieldType[
      :name => 'Spec type modified'
    ].id

    visit(index_url)

    # Find the correct checkbox
    check("custom_field_type_#{type_id}")

    click_on(delete_button)

    page.has_content?('Spec type modified').should == false
    page.all('table tbody tr').count.should        == rows
  end

  it 'Call the event new_custom_field_type (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_new_custom_field_type) do |type|
      type.name += ' with event'
    end

    Zen::Event.listen(:after_new_custom_field_type) do |type|
      event_name = type.name
    end

    visit(index_url)
    click_on(new_button)

    within '#custom_field_type_form' do
      fill_in('form_name', :with => 'Field type')

      fill_in(
        'form_language_string',
        :with => 'custom_fields.special.type_hash.textarea'
      )

      select('textarea', :from => 'custom_field_method_id')
      click_on(save_button)
    end

    page.has_selector?('span.error').should       == false
    page.find('input[name="name"]').value.should  == 'Field type with event'
    event_name.should                             == 'Field type with event'

    Zen::Event.delete(
      :before_new_custom_field_type,
      :after_new_custom_field_type
    )
  end

  it 'Call the event edit_custom_field_type (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_edit_custom_field_type) do |type|
      type.name = 'Field type modified'
    end

    Zen::Event.listen(:after_edit_custom_field_type) do |type|
      event_name = type.name
    end

    visit(index_url)
    click_on('Field type with event')

    within '#custom_field_type_form' do
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Field type modified'
    event_name.should                            == 'Field type modified'

    Zen::Event.delete(
      :before_edit_custom_field_type,
      :after_edit_custom_field_type
    )
  end

  it 'Call the event delete_custom_field_type (before and after)' do
    event_name  = nil
    event_name2 = nil
    type_id     = CustomFields::Model::CustomFieldType[
      :name => 'Field type modified'
    ].id

    Zen::Event.listen(:before_delete_custom_field_type) do |type|
      event_name = type.name
    end

    Zen::Event.listen(:after_delete_custom_field_type) do |type|
      event_name2 = type.name
    end

    visit(index_url)
    check("custom_field_type_#{type_id}")
    click_on(delete_button)

    page.has_content?('Field type modified').should == false
    event_name.should                               == 'Field type modified'
    event_name2.should                              == event_name

    Zen::Event.delete(
      :before_delete_custom_field_type,
      :after_delete_custom_field_type
    )
  end
end # describe
