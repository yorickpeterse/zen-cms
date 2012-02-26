require File.expand_path('../../../../../helper', __FILE__)

describe "Sections::Controller::SectionEntries" do
  behaves_like :capybara

  textbox_id  = CustomFields::Model::CustomFieldType[:name => 'textbox'].id
  checkbox_id = CustomFields::Model::CustomFieldType[:name => 'checkbox'].id
  section     = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => true,
    :comment_require_account => true,
    :comment_moderate        => true,
    :comment_format          => 'plain'
  )

  group = CustomFields::Model::CustomFieldGroup.create(:name => 'Spec fields')

  field = CustomFields::Model::CustomField.create(
    :name                  => 'Spec field',
    :sort_order            => 0,
    :format                => 'markdown',
    :required              => true,
    :text_editor           => false,
    :custom_field_group_id => group.id,
    :custom_field_type_id  => textbox_id
  )

  field_1 = CustomFields::Model::CustomField.create(
    :name                  => 'Spec checkbox',
    :sort_order            => 1,
    :format                => 'plain',
    :required              => true,
    :text_editor           => false,
    :custom_field_group_id => group.id,
    :custom_field_type_id  => checkbox_id,
    :possible_values       => "Yorick Peterse|yorick\nChuck Norris|chuck"
  )

  # Link the custom field group and the section
  section.custom_field_group_pks = [group.id]

  index_url = Sections::Controller::SectionEntries.r(:index, section.id).to_s
  new_url   = Sections::Controller::SectionEntries.r(:new, section.id).to_s
  edit_url  = Sections::Controller::SectionEntries.r(:edit, section.id).to_s
  new_button    = lang('section_entries.buttons.new')
  save_button   = lang('section_entries.buttons.save')
  delete_button = lang('section_entries.buttons.delete')
  title_field   = lang('section_entries.labels.title')
  status_field  = lang('section_entries.special.status_hash.published')

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      Sections::Controller::SectionEntries.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Find no existing entries' do
    message = lang('section_entries.messages.no_entries')

    visit(index_url)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  it "Create a new section entry" do
    visit(index_url)
    click_link(new_button)

    current_path.should                  == new_url
    page.has_field?('Spec field').should == true

    within '#section_entry_form' do
      fill_in(title_field , :with => 'Spec entry')
      select(status_field , :from => 'form_section_entry_status_id')
      fill_in('Spec field', :with => 'Spec field value')
      check("form_custom_field_value_#{field_1.id}_0")
      click_on(save_button)
    end

    current_path.should                           =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="title"]').value.should == 'Spec entry'
    page.find('input[name="slug"]').value.should  == 'spec-entry'

    page.find('select[name="section_entry_status_id"] option[selected]') \
      .text.should == status_field

    page.find_field('Spec checkbox').value.should == 'yorick'
    page.find_field('Spec field').value.should    == 'Spec field value'
  end

  it 'Try to create a new entry with invalid data' do
    visit(index_url)
    click_link(new_button)

    within '#section_entry_form' do
      fill_in(title_field, :with => 'Title')
      click_on(save_button)
    end

    page.find('input[name="title"]').value.should == 'Title'

    page.has_selector?(
      "label[for=\"form_custom_field_value_#{field.id}\"] span.error"
    ).should == true

    within '#section_entry_form' do
      fill_in(title_field, :with => '')
      fill_in(field.name, :with => 'Custom value')
      click_on(save_button)
    end

    page.has_selector?('label[for="form_title"] span.error').should == true
    page.find_field(field.name).value.should == 'Custom value'
  end

  it 'Search for a section entry' do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within '#search_form' do
      fill_in('query', :with => 'Spec entry')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec entry').should == true

    within '#search_form' do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec entry').should == false
  end

  it "Edit an existing section entry" do
    visit(index_url)
    click_link('Spec entry')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the entry
    within '#section_entry_form' do
      fill_in(title_field , :with => 'Spec entry modified')
      fill_in('Spec field', :with => 'Spec field value modified')
      check("form_custom_field_value_#{field_1.id}_1")
      click_on(save_button)
    end

    page.find('input[name="title"]').value.should == 'Spec entry modified'
    page.find_field('Spec field').value.should    == 'Spec field value modified'

    page.find_field("form_custom_field_value_#{field_1.id}_1") \
      .value.should == 'chuck'
  end

  enable_javascript

  it 'Automatically save a section entry' do
    visit(index_url)
    click_link('Spec entry modified')

    within '#section_entry_form' do
      fill_in('title', :with => 'Spec entry autosave')
    end

    click_link('Spec fields')

    within '#section_entry_form' do
      fill_in('Spec field', :with => 'Spec field value autosave')
    end

    autosave_form('section_entry_form')

    visit(index_url)

    page.has_content?('Spec entry autosave').should == true

    click_link('Spec entry autosave')

    page.find_field('Spec field').value.should == 'Spec field value autosave'

    within '#section_entry_form' do
      fill_in('title', :with => 'Spec entry modified')
    end

    click_link('Spec fields')

    within '#section_entry_form' do
      fill_in('Spec field', :with => 'Spec field value modified')
      click_on(save_button)
    end

    page.has_selector?('span.error').should       == false
    page.find('input[name="title"]').value.should == 'Spec entry modified'
    page.find_field('Spec field').value.should    == 'Spec field value modified'
  end

  disable_javascript

  it "Edit an existing section entry with invalid data" do
    visit(index_url)
    click_link('Spec entry')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the entry
    within '#section_entry_form' do
      fill_in(field.name , :with => '')
      click_on(save_button)
    end

    page.has_selector?(
      "label[for=\"form_custom_field_value_#{field.id}\"] span.error"
    ).should == true
  end

  it 'Fail to delete an entry without an ID' do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="section_entry_ids[]"]').should == true
  end

  it "Delete an existing section entry" do
    visit(index_url)

    # Mark the entry
    check('section_entry_ids[]')
    click_on(delete_button)

    page.has_content?('Spec entry modified').should == false
  end

  it 'Call the event new_section_entry (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_new_section_entry) do |entry|
      entry.title += ' with event'
    end

    Zen::Event.listen(:after_new_section_entry) do |entry|
      event_name = entry.title
    end

    visit(index_url)
    click_on(new_button)

    within '#section_entry_form' do
      fill_in(title_field , :with => 'Entry')
      select(status_field , :from => 'form_section_entry_status_id')
      fill_in('Spec field', :with => 'Spec field value')
      check("form_custom_field_value_#{field_1.id}_0")
      click_on(save_button)
    end

    page.has_selector?('span.error').should       == false
    page.find('input[name="title"]').value.should == 'Entry with event'
    event_name.should                             == 'Entry with event'

    Zen::Event.delete(:before_new_section_entry, :after_new_section_entry)
  end

  it 'Call the event edit_section_entry (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_edit_section_entry) do |entry|
      entry.title = 'Entry modified'
    end

    Zen::Event.listen(:after_edit_section_entry) do |entry|
      event_name = entry.title
    end

    visit(index_url)
    click_on('Entry with event')

    within '#section_entry_form' do
      click_on(save_button)
    end

    page.has_selector?('span.error').should       == false
    page.find('input[name="title"]').value.should == 'Entry modified'
    event_name.should                             == 'Entry modified'

    Zen::Event.delete(:before_edit_section_entry, :after_edit_section_entry)
  end

  it 'Call the event delete_section_entry (before and after)' do
    event_name  = nil
    event_name2 = nil
    message     = lang('section_entries.messages.no_entries')

    Zen::Event.listen(:before_delete_section_entry) do |entry|
      event_name = entry.title
    end

    Zen::Event.listen(:after_delete_section_entry) do |entry|
      event_name2 = entry.title
    end

    visit(index_url)
    check('section_entry_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           == true
    event_name.should                           == 'Entry modified'
    event_name2.should                          == event_name

    Zen::Event.delete(:before_delete_section_entry, :after_delete_section_entry)
  end

  field.destroy
  field_1.destroy
  group.destroy
  section.destroy
end
