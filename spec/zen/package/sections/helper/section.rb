require File.expand_path('../../../../../helper', __FILE__)

describe 'Ramaze::Helper::Section' do
  behaves_like :capybara

  status_id = Sections::Model::SectionEntryStatus[:name => 'published'].id
  user_id   = Users::Model::User[:email => 'spec@domain.tld'].id
  section   = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => false,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'markdown'
  )

  entry = Sections::Model::SectionEntry.create(
    :title                   => 'Spec entry',
    :user_id                 => user_id,
    :section_entry_status_id => status_id,
    :section_id              => section.id
  )

  it 'Validate a valid section' do
    url = Sections::Controller::Sections.r(:edit, section.id).to_s

    visit(url)

    current_path.should == url
  end

  it 'Validate an invalid section' do
    url   = Sections::Controller::Sections.r(:edit, section.id + 1).to_s
    index = Sections::Controller::Sections.r(:index).to_s

    visit(url)

    current_path.should == index
  end

  it 'Validate a valid section entry' do
    url = Sections::Controller::SectionEntries.r(
      :edit, section.id, entry.id
    ).to_s

    visit(url)

    current_path.should == url
  end

  it 'Validate an invalid section entry' do
    index = Sections::Controller::SectionEntries.r(:index, section.id).to_s
    url   = Sections::Controller::SectionEntries.r(
      :edit, section.id, entry.id + 1
    ).to_s

    visit(url)

    current_path.should == index
  end

  entry.destroy
  section.destroy
end
