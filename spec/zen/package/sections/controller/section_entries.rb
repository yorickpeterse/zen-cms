require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('section_entries')

# Run the actual test
describe("Sections::Controller::SectionEntries") do
  behaves_like :capybara

  textbox_id  = CustomFields::Model::CustomFieldType[:name => 'textbox'].id
  checkbox_id = CustomFields::Model::CustomFieldType[:name => 'checkbox'].id
  @section    = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => true,
    :comment_require_account => true,
    :comment_moderate        => true,
    :comment_format          => 'plain'
  )

  @group = CustomFields::Model::CustomFieldGroup.create(
    :name => 'Spec fields'
  )

  @field = CustomFields::Model::CustomField.create(
    :name                  => 'Spec field',
    :sort_order            => 0,
    :format                => 'markdown',
    :required              => true,
    :text_editor           => false,
    :custom_field_group_id => @group.id,
    :custom_field_type_id  => textbox_id
  )

  @field_1 = CustomFields::Model::CustomField.create(
    :name                  => 'Spec checkbox',
    :sort_order            => 1,
    :format                => 'plain',
    :required              => true,
    :text_editor           => false,
    :custom_field_group_id => @group.id,
    :custom_field_type_id  => checkbox_id,
    :possible_values       => "Yorick Peterse|yorick\nChuck Norris|chuck"
  )

  # Link the custom field group and the section
  @section.custom_field_group_pks = [@group.id]

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Sections::Controller::SectionEntries.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No section entries should exist") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s

    message = lang('section_entries.messages.no_entries')

    visit(index_url)

    page.has_selector?('table tbody tr').should === false
    page.has_content?(message).should           === true
  end

  it("Create a new section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s
    new_url   = Sections::Controller::SectionEntries.r(
      :new, @section.id
    ).to_s
    edit_url  = Sections::Controller::SectionEntries.r(
      :edit, @section.id
    ).to_s

    field_id     = @field.id
    new_entry    = lang('section_entries.buttons.new')
    save_entry   = lang('section_entries.buttons.save')
    title_field  = lang('section_entries.labels.title')
    status_field = lang('section_entries.special.status_hash.published')

    visit(index_url)
    click_link(new_entry)

    current_path.should                  === new_url
    page.has_field?('Spec field').should === true

    within('#section_entry_form') do
      fill_in(title_field , :with => 'Spec entry')
      select(status_field , :from => 'form_section_entry_status_id')
      fill_in('Spec field', :with => 'Spec field value')
      check("form_custom_field_value_#{@field_1.id}_0")
      click_on(save_entry)
    end

    current_path.should                           =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="title"]').value.should === 'Spec entry'

    page.find('select[name="section_entry_status_id"] option[selected]') \
      .text.should === status_field

    page.find_field('Spec checkbox').value.should === 'yorick'
    page.find_field('Spec field').value.should    === 'Spec field value'
  end

  it("Edit an existing section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s
    edit_url  = Sections::Controller::SectionEntries.r(
      :edit, @section.id
    ).to_s

    title_field = lang('section_entries.labels.title')
    save_entry  = lang('section_entries.buttons.save')

    visit(index_url)
    click_link('Spec entry')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the entry
    within('#section_entry_form') do
      fill_in(title_field , :with => 'Spec entry modified')
      fill_in('Spec field', :with => 'Spec field value modified')
      check("form_custom_field_value_#{@field_1.id}_1")
      click_on(save_entry)
    end

    page.find('input[name="title"]').value.should === 'Spec entry modified'
    page.find_field('Spec field').value.should    === 'Spec field value modified'

    page.find_field("form_custom_field_value_#{@field_1.id}_1") \
      .value.should === 'chuck'
  end

  it("Edit an existing section entry with invalid data") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s
    edit_url  = Sections::Controller::SectionEntries.r(
      :edit, @section.id
    ).to_s

    title_field = lang('section_entries.labels.title')
    save_entry  = lang('section_entries.buttons.save')

    visit(index_url)
    click_link('Spec entry')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    # Update the entry
    within('#section_entry_form') do
      fill_in(@field.name , :with => '')
      click_on(save_entry)
    end

    page.has_selector?(
      "label[for=\"form_custom_field_value_#{@field.id}\"] span.error"
    ).should === true
  end

  it('Try to delete an entry without an ID') do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s

    delete_button = lang('section_entries.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="section_entry_ids[]"]').should === true
  end

  it("Delete an existing section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, @section.id
    ).to_s

    delete_button = lang('section_entries.buttons.delete')

    visit(index_url)

    # Mark the entry
    check('section_entry_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
  end

  @field.destroy
  @field_1.destroy
  @group.destroy
  @section.destroy
end
