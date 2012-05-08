require File.expand_path('../../../../../helper', __FILE__)

describe 'Sections::Model::Revision' do
  behaves_like :capybara

  textbox_id  = CustomFields::Model::CustomFieldType[:name => 'textbox'].id
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

  section.custom_field_group_pks = [group.id]

  entries_url = Sections::Controller::SectionEntries.r(:index, section.id).to_s
  new_button  = lang('section_entries.buttons.new')
  save_button = lang('section_entries.buttons.save')
  title_field = lang('section_entries.labels.title')

  it 'The last revision should not be deleted' do
    visit(entries_url)

    click_on(new_button)

    within '#section_entry_form' do
      fill_in(title_field, :with => 'Title')
      fill_in(field.name, :with => 'Original value')

      click_on(save_button)
    end

    page.has_selector?('.message.error').should == false

    10.times do |t|
      within '#section_entry_form' do
        fill_in(field.name, :with => "Modified #{t}")

        click_on(save_button)
      end
    end

    entry     = Sections::Model::SectionEntry[:title => 'Title']
    revisions = entry.revisions

    revisions.length.should == 10

    revisions[1..-1].each { |rev| rev.destroy }

    should.raise?(Sequel::Error::InvalidOperation) do
      revisions[0].destroy
    end

    Sections::Model::Revision \
      .filter(:section_entry_id => entry.id) \
      .count \
      .should == 1
  end

  field.destroy
  section.destroy
  group.destroy
end
