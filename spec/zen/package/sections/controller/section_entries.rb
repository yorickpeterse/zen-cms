require File.expand_path('../../../../../helper', __FILE__)

# Run the actual test
describe("Sections::Controller::SectionEntries", :type => :acceptance, :auto_login => true) do
  
  it("Create the test data") do
    Testdata[:section] = Sections::Model::Section.new(
      :name => 'Spec section', :comment_allow => true, :comment_require_account => true,
      :comment_moderate => true, :comment_format => 'plain'
    )
    Testdata[:section].save

    Testdata[:group] = CustomFields::Model::CustomFieldGroup.new(:name => 'Spec fields')
    Testdata[:group].save

    Testdata[:field] = CustomFields::Model::CustomField.new(
      :name => 'Spec field', :sort_order => 0, :type => 'textbox', :format => 'markdown',
      :required => true, :visual_editor => false, 
      :custom_field_group_id => Testdata[:group].id
    )
    Testdata[:field].save

    # Link the custom field group and the section
    Testdata[:section].custom_field_group_pks = [Testdata[:group].id]

    Zen::Language.load('section_entries')
  end

  it("No section entries should exist") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, Testdata[:section].id
    ).to_s

    message = lang('section_entries.messages.no_entries')

    visit(index_url)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should == true
  end

  it("Create a new section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, Testdata[:section].id
    ).to_s
    new_url   = Sections::Controller::SectionEntries.r(
      :new, Testdata[:section].id
    ).to_s
    edit_url  = Sections::Controller::SectionEntries.r(
      :edit, Testdata[:section].id
    ).to_s

    field_id     = Testdata[:field].id
    new_entry    = lang('section_entries.buttons.new')
    save_entry   = lang('section_entries.buttons.save')
    title_field  = lang('section_entries.labels.title')
    status_field = lang('section_entries.special.status_hash.published')

    visit(index_url)
    click_link(new_entry)

    current_path.should === new_url

    within('#section_entry_form') do
      fill_in(title_field  , :with => 'Spec entry')
      select(status_field  , :from => 'form_section_entry_status_id')
      fill_in('Spec field' , :with => 'Spec field value')
      click_on(save_entry)
    end

    current_path.should                             =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="title"]').value.should   === 'Spec entry'

    page.find('select[name="section_entry_status_id"] option[selected]') \
      .text.should === status_field
    
    page.find_field('Spec field').value.should      === 'Spec field value'
  end

  it("Edit an existing section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, Testdata[:section].id
    ).to_s
    edit_url  = Sections::Controller::SectionEntries.r(
      :edit, Testdata[:section].id
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
      click_on(save_entry)
    end

    page.find('input[name="title"]').value.should === 'Spec entry modified'
    page.find_field('Spec field').value.should    === 'Spec field value modified'
  end

  it("Delete an existing section entry") do
    index_url = Sections::Controller::SectionEntries.r(
      :index, Testdata[:section].id
    ).to_s

    delete_button = lang('section_entries.buttons.delete')

    visit(index_url)

    # Mark the entry
    check('section_entry_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
  end

  it("Delete the test data") do
    Testdata[:field].destroy
    Testdata[:group].destroy
    Testdata[:section].destroy
  end

end
