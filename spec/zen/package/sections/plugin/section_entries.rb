require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::SectionEntries') do
  include ::Sections::Model
  include ::Comments::Model

  it('Create the test data') do
    user               = Users::Model::User[:email => 'spec@domain.tld']
    Testdata[:section] = Section.new(
      :name => 'Spec', :comment_allow => true, :comment_require_account => false,
      :comment_moderate => false, :comment_format => 'plain'
    ).save

    Testdata[:entry_1] = SectionEntry.new(
      :title => 'Spec', :status => 'published', :user_id => user.id, 
      :section_id => Testdata[:section].id
    ).save

    Testdata[:entry_2] = SectionEntry.new(
      :title => 'Spec 1', :status => 'published', :user_id => user.id, 
      :section_id => Testdata[:section].id
    ).save

    Testdata[:comment] = Comment.new(
      :user_id => user.id, :comment => 'spec comment', :status => 'open',
      :section_entry_id => Testdata[:entry_2].id, :comment => 'Comment', 
      :email => user.email
    ).save  
  end

  it('Retrieve all section entries') do
    entries = Zen::Plugin.call('com.zen.plugin.section_entries', :section => 'spec')

    entries.count.should                      === 2
    entries[0].class.should                   ==  Hash
    entries[0][:title].should                 === 'Spec'
    entries[1][:title].should                 === 'Spec 1'
    entries[1][:user][:name].should           === 'Spec'
    entries[1][:comments].empty?.should       === false
    entries[1][:comments][0][:comment].should === 'Comment'
  end

  it('Retrieve all section entries for an ID') do
    entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => Testdata[:section].id
    )

    entries.count.should      === 2
    entries[0].class.should   ==  Hash
    entries[0][:title].should === 'Spec'
    entries[1][:title].should === 'Spec 1'
  end

  it('Retrieve a single entry by it\'s slug') do
    entry = Zen::Plugin.call('com.zen.plugin.section_entries', :entry => 'spec')

    entry.class.should   == Hash
    entry[:title].should === 'Spec'
    entry[:id].should    === Testdata[:entry_1].id
  end

  it('Retrieve a single entry by it\'s ID') do
    entry = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :entry => Testdata[:entry_1].id
    )

    entry.class.should   == Hash
    entry[:title].should === 'Spec'
    entry[:id].should    === Testdata[:entry_1].id
  end

  it('Limit the amount of entries') do
        entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => 'spec', :limit => 1
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec'
  end

  it('Limit the amount of entries with an offset') do
        entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => 'spec', :limit => 1, :offset => 1
    )

    entries.count.should      === 1
    entries[0][:title].should === 'Spec 1'
  end

  it('Delete the test data') do
    [:comment, :entry_2, :entry_1, :section].each do |k|
      Testdata[k].destroy
    end
  end

end

