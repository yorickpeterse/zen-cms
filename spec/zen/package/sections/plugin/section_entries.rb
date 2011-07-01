require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::SectionEntries') do
  extend ::Sections::Model
  extend ::Comments::Model

  it('Create the test data') do
    user               = Users::Model::User[:email => 'spec@domain.tld']
    status_id          = SectionEntryStatus[:name => 'published'].id
    comment_status     = CommentStatus[:name => 'open'].id

    @section = Section.create(
      :name                     => 'Spec', 
      :comment_allow            => true, 
      :comment_require_account  => false,
      :comment_moderate         => false, 
      :comment_format           => 'plain'
    )

    @entry_1 = SectionEntry.create(
      :title                   => 'Spec', 
      :status                  => 'published',
      :user_id                 => user.id, 
      :section_id              => @section.id,
      :slug                    => 'spec',
      :section_entry_status_id => status_id
    )

    @entry_2 = SectionEntry.create(
      :title                    => 'Spec 1', 
      :status                   => 'published', 
      :user_id                  => user.id, 
      :section_id               => @section.id,
      :slug                     => 'spec-1',
      :section_entry_status_id  => status_id
    )

    @comment = Comment.create(
      :user_id           => user.id, 
      :comment_status_id => comment_status,
      :section_entry_id  => @entry_2.id, 
      :comment           => 'Comment', 
      :email             => user.email
    )

    @section.name.should    === 'Spec'
    @entry_1.title.should   === 'Spec'
    @entry_2.title.should   === 'Spec 1'
    @comment.comment.should === 'Comment'
  end

  it('Retrieve all section entries') do
    entries = plugin(:section_entries, :section => 'spec', :comments => true)

    entries.count.should                      === 2
    entries[0].class.should                   ==  Hash
    entries[0][:title].should                 === 'Spec'
    entries[1][:title].should                 === 'Spec 1'
    entries[1][:user][:name].should           === 'Spec'
    entries[1][:comments].empty?.should       === false
    entries[1][:comments][0][:comment].should === 'Comment'
  end

  it('Retrieve all section entries for an ID') do
    entries = plugin(
      :section_entries, :section => @section.id
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
    entry[:id].should    === @entry_1.id
  end

  it('Retrieve a single entry by it\'s ID') do
    entry = plugin(
      :section_entries, :entry => @entry_1.id
    )

    entry.class.should   == Hash
    entry[:title].should === 'Spec'
    entry[:id].should    === @entry_1.id
  end

  it('Limit the amount of entries') do
        entries = plugin(
      :section_entries, :section => 'spec', :limit => 1
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec'
  end

  it('Limit the amount of entries with an offset') do
        entries = plugin(
      :section_entries, :section => 'spec', :limit => 1, :offset => 1
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec 1'
  end

  it('Delete the test data') do
    [@comment, @entry_2, @entry_1, @section].each do |k|
      k.destroy
    end

    Section[:name => 'Spec'].should            === nil
    SectionEntry[:title => 'Spec'].should      === nil
    SectionEntry[:title => 'Spec 1'].should    === nil
    Comment[:comment => 'spec comment'].should === nil
  end

end

