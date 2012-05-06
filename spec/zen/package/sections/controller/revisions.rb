require File.expand_path('../../../../../helper', __FILE__)

describe 'Sections::Controller::Revisions' do
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

  section.custom_field_group_pks = [group.id]

  entries_url    = Sections::Controller::SectionEntries.r(:index, section.id).to_s
  edit_url       = Sections::Controller::SectionEntries.r(:edit, section.id).to_s
  revisions_url  = lang('revisions.titles.index')
  restore_url    = lang('revisions.labels.restore')
  new_button     = lang('section_entries.buttons.new')
  save_button    = lang('section_entries.buttons.save')
  compare_button = lang('revisions.buttons.compare')
  title_field    = lang('section_entries.labels.title')

  it 'Create a new revision each time a section entry is saved' do
    visit(entries_url)

    click_on(new_button)

    within '#section_entry_form' do
      fill_in(title_field, :with => 'Entry with revisions')
      fill_in(field.name, :with => 'Original value')
      check("form_custom_field_value_#{field_1.id}_0")

      click_on(save_button)
    end

    current_path.should                         =~ /#{edit_url}\/[0-9]+/
    page.has_selector?('.message.error').should == false

    9.times do |number|
      within '#section_entry_form' do
        fill_in(field.name, :with => "Modified #{number}")

        click_on(save_button)
      end
    end

    page.find_field(field.name).value.should == 'Modified 8'

    Sections::Model::SectionEntry[:title => 'Entry with revisions'] \
      .revisions.length.should == 10
  end

  it 'Compare two different revisions' do
    entry = Sections::Model::SectionEntry[:title => 'Entry with revisions']
    url   = Sections::Controller::Revisions \
      .r(:index, entry.section_id, entry.id) \
      .to_s

    revisions = Sections::Model::Revision.filter(:section_entry_id => entry.id) \
      .order(:id.asc) \
      .all

    visit(entries_url)
    click_on(revisions_url)

    page.current_path.should                == url
    page.all('table tbody tr').count.should == 10

    choose("old_revision_id_#{revisions[0].id}")
    choose("new_revision_id_#{revisions[1].id}")

    click_on(compare_button)

    page.has_selector?('.diff').should              == true
    page.has_selector?('.diff .ins').should         == true
    page.has_selector?('.diff .del').should         == true
    page.has_selector?('.diff .line_number').should == true

    page.has_content?('Original value').should == true
    page.has_content?('Modified 0').should     == true

    page.find('.diff .del').text.strip.should == '-Original value'
    page.find('.diff .ins').text.strip.should == '+Modified 0'

    choose("old_revision_id_#{revisions[1].id}")
    choose("new_revision_id_#{revisions[2].id}")

    click_on(compare_button)

    page.find('.diff .del').text.strip.should == '-Modified 0'
    page.find('.diff .ins').text.strip.should == '+Modified 1'
  end

  it 'Compare the same two revisions' do
    entry = Sections::Model::SectionEntry[:title => 'Entry with revisions']
    url   = Sections::Controller::Revisions \
      .r(:index, entry.section_id, entry.id) \
      .to_s

    revisions = Sections::Model::Revision.filter(:section_entry_id => entry.id) \
      .order(:id.asc) \
      .all

    visit(entries_url)
    click_on(revisions_url)

    page.current_path.should                == url
    page.all('table tbody tr').count.should == 10

    choose("old_revision_id_#{revisions[0].id}")
    choose("new_revision_id_#{revisions[0].id}")

    click_on(compare_button)

    page.has_selector?('.diff').should                                  == false
    page.has_content?(lang('revisions.messages.no_differences')).should == true
  end

  it 'The oldest revision should be removed if the limit is exceeded' do
    entry  = Sections::Model::SectionEntry[:title => 'Entry with revisions']
    oldest = entry.revisions[-1].id

    visit(entries_url)

    click_on('Entry with revisions')

    5.times do |number|
      within '#section_entry_form' do
        fill_in(field.name, :with => "Overwritten #{number}")
        click_on(save_button)
      end
    end

    revisions = Sections::Model::Revision.filter(:section_entry_id => entry.id) \
      .order(:id.asc) \
      .all

    revisions.length.should == 10
    revisions[0].id.should  > oldest
  end

  it 'Gracefully handle non numeric revision IDs' do
    visit(entries_url)
    visit(Sections::Controller::Revisions.r(:restore, 'a').to_s)

    page.current_path.should                    == entries_url
    page.has_selector?('.message.error').should == true
  end

  it 'Restore a revision and delete newer revisions' do
    visit(entries_url)
    click_on(revisions_url)

    within 'table tbody tr:last-child' do
      click_on(restore_url)
    end

    page.has_selector?('.message.success').should == true
    page.all('table tbody tr').count.should       == 1

    Sections::Model::SectionEntry[:title => 'Entry with revisions'] \
      .revisions \
      .length \
      .should == 1

    visit(entries_url)
    click_on('Entry with revisions')

    page.find_field(field.name).value.should == 'Modified 4'
  end

  it 'Compare array based values of two revisions' do
    visit(entries_url)

    click_on('Entry with revisions')

    within '#section_entry_form' do
      check("form_custom_field_value_#{field_1.id}_1")
      click_on(save_button)
    end

    page.has_selector?('.message.error').should == false

    visit(entries_url)
    click_on(revisions_url)

    entry     = Sections::Model::SectionEntry[:title => 'Entry with revisions']
    revisions = Sections::Model::Revision.filter(:section_entry_id => entry.id) \
      .order(:id.asc) \
      .all

    choose("old_revision_id_#{revisions[-1].id}")
    choose("new_revision_id_#{revisions[-2].id}")

    click_on(compare_button)

    page.has_selector?('.diff .ins').should == false
    page.has_selector?('.diff .del').should == true

    page.has_content?('yorick').should == true
    page.has_content?('chuck').should  == true
  end

  field.destroy
  field_1.destroy
  group.destroy
  section.destroy
end
