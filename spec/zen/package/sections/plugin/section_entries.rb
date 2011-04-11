require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::Sections') do
  include ::Sections::Model

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
  end

  it('Retrieve all section entries') do
    entries = Zen::Plugin.call('com.zen.plugin.section_entries', :section => 'spec')

    entries.count.should    === 2
    entries[0].title.should === 'Spec'
    entries[1].title.should === 'Spec 1'
  end

  it('Retrieve all section entries for an ID') do
    entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => Testdata[:section].id
    )

    entries.count.should    === 2
    entries[0].title.should === 'Spec'
    entries[1].title.should === 'Spec 1'
  end

  it('Retrieve a single entry by it\'s slug') do
    entry = Zen::Plugin.call('com.zen.plugin.section_entries', :entry => 'spec')

    entry.title.should === 'Spec'
    entry.id.should    === Testdata[:entry_1].id
  end

  it('Retrieve a single entry by it\'s ID') do
    entry = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :entry => Testdata[:entry_1].id
    )

    entry.title.should === 'Spec'
    entry.id.should    === Testdata[:entry_1].id
  end

  it('Limit the amount of entries') do
        entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => 'spec', :limit => 1
    )

    entries.count.should    === 1
    entries[0].title.should === 'Spec'
  end

  it('Limit the amount of entries with an offset') do
        entries = Zen::Plugin.call(
      'com.zen.plugin.section_entries', :section => 'spec', :limit => 1, :offset => 1
    )

    entries.count.should    === 1
    entries[0].title.should === 'Spec 1'
  end

  it('Delete the test data') do
    [:entry_2, :entry_1, :section].each do |k|
      Testdata[k].destroy
    end
  end

end

