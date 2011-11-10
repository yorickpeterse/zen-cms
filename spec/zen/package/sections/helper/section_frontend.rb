require File.expand_path('../../../../../helper', __FILE__)
require File.join(
  Zen::FIXTURES,
  'package',
  'sections',
  'helper',
  'section_frontend'
)

describe('Ramaze::Helper::SectionFrontend') do
  extend       Ramaze::Helper::SectionFrontend
  behaves_like :capybara

  user           = Users::Model::User[:email => 'spec@domain.tld']
  status_id      = Sections::Model::SectionEntryStatus[:name => 'published'].id
  comment_status = Comments::Model::CommentStatus[:name => 'open'].id

  section = Sections::Model::Section.create(
    :name                     => 'Spec',
    :comment_allow            => true,
    :comment_require_account  => false,
    :comment_moderate         => false,
    :comment_format           => 'plain'
  )

  entry_1 = Sections::Model::SectionEntry.create(
    :title                   => 'Spec',
    :user_id                 => user.id,
    :section_id              => section.id,
    :slug                    => 'spec',
    :section_entry_status_id => status_id
  )

  entry_2 = Sections::Model::SectionEntry.create(
    :title                    => 'Spec 1',
    :user_id                  => user.id,
    :section_id               => section.id,
    :slug                     => 'spec-1',
    :section_entry_status_id  => status_id
  )

  comment = Comments::Model::Comment.create(
    :user_id           => user.id,
    :comment_status_id => comment_status,
    :section_entry_id  => entry_2.id,
    :comment           => 'Comment',
    :email             => user.email
  )

  category_group = Categories::Model::CategoryGroup.create(
    :name => 'spec category group'
  )

  category = Categories::Model::Category.create(
    :name              => 'spec category',
    :category_group_id => category_group.id
  )

  type   = CustomFields::Model::CustomFieldType[:name => 'textbox']
  group = CustomFields::Model::CustomFieldGroup.create(
    :name => 'Spec group'
  )

  field = CustomFields::Model::CustomField.create(
    :name                  => 'Spec field',
    :format                => 'markdown',
    :text_editor           => false,
    :required              => false,
    :custom_field_group_id => group.id,
    :custom_field_type_id  => type.id
  )

  section.category_group_pks = [category_group.id]

  entry_1.add_category(category)
  entry_1.add_custom_field_value(
    :custom_field_id => field.id,
    :value           => 'hello'
  )

  should('retrieve all section entries') do
    entries = get_entries(
      section.slug,
      :comments   => true,
      :categories => true,
      :order      => :asc
    )

    entries.length.should                 == 2
    entries[0].title.should               == 'Spec'
    entries[1].title.should               == 'Spec 1'
    entries[1].user.name.should           == 'Spec'

    entries[1].comments.empty?.should     == false
    entries[1].comments[0].comment.should == 'Comment'

    entries[0].categories.empty?.should   == false
    entries[0].categories[0].name.should  == 'spec category'

    entries[0].fields[:'spec-field'].strip.should == '<p>hello</p>'
  end

  should('retrieve all section entries but sort descending') do
    entries = get_entries(section.slug, :comments => true, :categories => true)

    entries[0].title.should == 'Spec 1'
    entries[1].title.should == 'Spec'
  end

  should('retrieve all section entries for an ID') do
    entries = get_entries(section.id, :order => :asc)

    entries.length.should   == 2
    entries[0].title.should == 'Spec'
    entries[1].title.should == 'Spec 1'
  end

  should('retrieve a single entry by it\'s slug') do
    entry = get_entry(entry_1.slug)

    entry.title.should == 'Spec'
    entry.id.should    == entry_1.id
  end

  should('retrieve a single entry by it\'s ID') do
    entry = get_entry(entry_1.id)

    entry.title.should == 'Spec'
    entry.id.should    == entry_1.id
  end

  should('Paginate a set of entries') do
    visit('/spec-section-frontend')

    page.has_selector?('p').should         == true
    page.has_selector?('.pager').should    == true
    page.all('p').length.should            == 1
    page.find('p:first-child').text.should == entry_2.title

    visit('/spec-section-frontend?page=2')

    page.has_selector?('p').should         == true
    page.has_selector?('.pager').should    == true
    page.all('p').length.should            == 1
    page.find('p:first-child').text.should == entry_1.title
  end

  [
    field,
    group,
    category,
    category_group,
    comment,
    entry_2,
    entry_1,
    section
  ].each do |k|
    k.destroy
  end
end # describe
