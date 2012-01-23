require File.expand_path('../../../../helper', __FILE__)

describe 'Recent Entries widget' do
  WebMock.disable!
  Capybara.current_driver = Capybara.javascript_driver
  behaves_like :capybara

  status_id = Sections::Model::SectionEntryStatus[:name => 'published'].id
  user_id   = Users::Model::User[:email => 'spec@domain.tld'].id
  entries   = []
  section   = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => false,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'markdown'
  )

  10.times do |t|
    entries << Sections::Model::SectionEntry.create(
      :title                   => "Spec entry #{t}",
      :user_id                 => user_id,
      :section_entry_status_id => status_id,
      :section_id              => section.id
    )
  end

  it 'Show a widget containing the 10 most recent entries' do
    visit(Dashboard::Controller::Dashboard.r(:index).to_s)

    check('toggle_widget_recent_entries')

    page.has_content?(lang('section_entries.widgets.titles.recent_entries')) \
      .should == true

    page.has_selector?('#widget_recent_entries').should      == true
    page.has_content?('Spec entry 1').should                 == true
    page.all('#widget_recent_entries tbody tr').count.should == 10
  end

  entries.reverse.each { |e| e.destroy }
  section.destroy

  Capybara.use_default_driver
  WebMock.enable!
end
