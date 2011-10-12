require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::SectionEntries') do
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

  it('Raise when no section or entry has been specified') do
    should.raise?(ArgumentError) do
      plugin(:section_entries)
    end
  end

  it('Retrieve all section entries') do
    entries = plugin(
      :section_entries,
      :section    => 'spec',
      :comments   => true,
      :categories => true,
      :order      => :asc
    )

    entries.count.should                      === 2
    entries[0].class.should                   ==  Hash
    entries[0][:title].should                 === 'Spec'
    entries[1][:title].should                 === 'Spec 1'
    entries[1][:user][:name].should           === 'Spec'

    entries[1][:comments].empty?.should       === false
    entries[1][:comments][0][:comment].should === 'Comment'

    entries[0][:categories].empty?.should     === false
    entries[0][:categories][0][:name].should  === 'spec category'

    entries[0][:fields][:'spec-field'].strip.should === '<p>hello</p>'
  end

  it('Retrieve all section entries but sort descending') do
    entries = plugin(
      :section_entries,
      :section    => 'spec',
      :comments   => true,
      :categories => true
    )

    entries[0][:title].should === 'Spec 1'
    entries[1][:title].should === 'Spec'
  end

  it('Retrieve all section entries for an ID') do
    entries = plugin(
      :section_entries,
      :section => section.id,
      :order   => :asc
    )

    entries.count.should      === 2
    entries[0].class.should   ==  Hash
    entries[0][:title].should === 'Spec'
    entries[1][:title].should === 'Spec 1'
  end

  it('Retrieve a single entry by it\'s slug') do
    entry = plugin(:section_entries, :entry => 'spec')

    entry.class.should   == Hash
    entry[:title].should === 'Spec'
    entry[:id].should    === entry_1.id
  end

  it('Retrieve a single entry by it\'s ID') do
    entry = plugin(
      :section_entries, :entry => entry_1.id
    )

    entry.class.should   == Hash
    entry[:title].should === 'Spec'
    entry[:id].should    === entry_1.id
  end

  it('Limit the amount of entries') do
    entries = plugin(
      :section_entries,
      :section => 'spec',
      :limit   => 1,
      :order   => :asc
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec'
  end

  it('Limit the amount of entries with an offset') do
    entries = plugin(
      :section_entries,
      :section => 'spec',
      :limit   => 1,
      :offset  => 1,
      :order   => :asc
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec 1'
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
