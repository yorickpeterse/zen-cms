require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package/comments/controller/comments_form')

describe("Comments::Controller::CommentsForm") do
  behaves_like :capybara

  before do
    get_setting(:defensio_key).value = 'test'
  end

  after do
    Comments::Model::Comment.destroy

    get_setting(:defensio_key).value = nil

    Zen::Event.delete(:before_new_comment, :after_new_comment)
  end

  # Set up all the required data
  get_setting(:enable_antispam).value   = false
  get_setting(:frontend_language).value = 'en'

  user_id      = Users::Model::User[:name => 'Spec'].id
  entry_status = Sections::Model::SectionEntryStatus[:name => 'published'].id

  section = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => true,
    :comment_require_account => true,
    :comment_moderate        => false,
    :comment_format          => 'plain',
  )

  section_entry = Sections::Model::SectionEntry.create(
    :title                   => 'Spec entry',
    :user_id                 => user_id,
    :section_entry_status_id => entry_status,
    :section_id              => section.id
  )

  it('Submit a comment without a CSRF token') do
    url      = Comments::Controller::CommentsForm.r(:save).to_s
    response = page.driver.post(url)

    response.body.should   == lang('zen_general.errors.csrf')
    response.status.should == 403
  end

  it('Submit a comment') do
    visit(SpecCommentsForm.r(:index).to_s)

    # Submit the form
    within('#spec_comments_form') do
      fill_in('user_id'      , :with => user_id)
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    comment = Comments::Model::Comment[:comment => 'Spec comment']

    comment.user_name.should  == 'Spec'
    comment.comment.should    == 'Spec comment'
    comment.user_email.should == 'spec@domain.tld'
    comment.section_entry_id  == section_entry.id
  end

  it('Submit a comment with custom events') do
    event_comment = nil

    Zen::Event.listen(:before_new_comment) do |comment|
      comment.comment = 'Spec comment event'
    end

    Zen::Event.listen(:after_new_comment) do |comment|
      event_comment = comment.comment
    end

    visit(SpecCommentsForm.r(:index).to_s)

    # Submit the form
    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    comment = Comments::Model::Comment[:comment => 'Spec comment event']

    comment.name.should      == 'Spec user'
    comment.comment.should   == 'Spec comment event'
    comment.website.should   == 'http://zen-cms.com/'
    comment.email.should     == 'spec@domain.tld'
    comment.section_entry_id == section_entry.id
    event_comment.should     == 'Spec comment event'
  end

  it('Fail to submit a comment with an invalid entry') do
    url = SpecCommentsForm.r(:index).to_s

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id + 1)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    page.body.include?(lang('comments.errors.invalid_entry')) \
      .should == true

    current_path.should == url
  end

  it('Should fail to submit a comment for an invalid section') do
    old_id = section_entry.section_id
    url    = SpecCommentsForm.r(:index).to_s

    section_entry.update(:section_id => nil)

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    page.body.include?(lang('comments.errors.invalid_entry')) \
      .should == true

    current_path.should == url

    section_entry.update(:section_id => old_id)
  end

  it('Should fail to submit a comment when comments are not allowed') do
    url = SpecCommentsForm.r(:index).to_s

    section.update(:comment_allow => false)
    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'S)ec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    page.body.include?(lang('comments.errors.comments_not_allowed')) \
      .should == true

    current_path.should == url

    section.update(:comment_allow => true)
  end

  it('Fail to submit a comment when not logged in') do
    url = SpecCommentsForm.r(:index).to_s

    visit(Users::Controller::Users.r(:logout).to_s)
    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    page.body.include?(lang('comments.errors.comments_require_account')) \
      .should == true

    current_path.should == url

    # Log back in
    capybara_login
  end

  it('Submit a comment with moderation turned on') do
    section.update(:comment_moderate => true)

    url           = SpecCommentsForm.r(:index).to_s
    closed_status = Comments::Model::CommentStatus[:name => 'closed']

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    page.body.include?(lang('comments.success.moderate')).should == true
    current_path.should                                          == url

    Comments::Model::Comment[:comment => 'Spec comment'] \
      .comment_status_id.should == closed_status.id

    section.update(:comment_moderate => false)
  end

  it('Submit a comment and mark it as ham') do
    yaml_response = <<-YAML.strip
    defensio-result:
      api-version: 2.0
      status: success
      message:
      signature: 1234abc
      allow: true
      classification: innocent
      spaminess: 0.5
      profanity-match: false
    YAML

    stub_request(
      :post,
      'http://api.defensio.com/2.0/users/test/documents.yaml'
    ).to_return(:body => yaml_response)

    get_setting(:enable_antispam).value = '1'

    url         = SpecCommentsForm.r(:index).to_s
    open_status = Comments::Model::CommentStatus[:name => 'open']

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec alternative')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'COMMENT')

      click_on('Submit')
    end

    page.body.include?(lang('comments.success.new')).should == true
    current_path.should                                     == url

    Comments::Model::Comment[:name => 'Spec alternative'] \
      .comment_status_id.should == open_status.id

    get_setting(:enable_antispam).value = '0'
    WebMock.reset!
  end

  it('Submit a comment and mark it as ham with moderation turned on') do
    yaml_response = <<-YAML.strip
    defensio-result:
      api-version: 2.0
      status: success
      message:
      signature: 1234abc
      allow: true
      classification: innocent
      spaminess: 0.5
      profanity-match: false
    YAML

    stub_request(
      :post,
      'http://api.defensio.com/2.0/users/test/documents.yaml'
    ).to_return(:body => yaml_response)

    get_setting(:enable_antispam).value = '1'

    section.update(:comment_moderate => true)

    url           = SpecCommentsForm.r(:index).to_s
    closed_status = Comments::Model::CommentStatus[:name => 'closed']

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec alternative')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'COMMENT')

      click_on('Submit')
    end

    page.body.include?(lang('comments.success.moderate')).should == true
    current_path.should                                          == url

    Comments::Model::Comment[:name => 'Spec alternative'] \
      .comment_status_id.should == closed_status.id

    get_setting(:enable_antispam).value = '0'
    WebMock.reset!

    section.update(:comment_moderate => false)
  end

  it('Submit a comment and mark it as spam') do
    yaml_response = <<-YAML.strip
    defensio-result:
      api-version: 2.0
      status: success
      message:
      signature: 1234abc
      allow: false
      classification: spam
      spaminess: 0.9
      profanity-match: false
    YAML

    stub_request(
      :post,
      'http://api.defensio.com/2.0/users/test/documents.yaml'
    ).to_return(:body => yaml_response)

    get_setting(:enable_antispam).value = '1'

    url         = SpecCommentsForm.r(:index).to_s
    spam_status = Comments::Model::CommentStatus[:name => 'spam']

    visit(url)

    within('#spec_comments_form') do
      fill_in('section_entry', :with => section_entry.id)
      fill_in('name'         , :with => 'Spec alternative')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'COMMENT')

      click_on('Submit')
    end

    page.body.include?(lang('comments.success.new')).should == true
    current_path.should                                     == url

    Comments::Model::Comment[:name => 'Spec alternative'] \
      .comment_status_id.should == spam_status.id

    get_setting(:enable_antispam).value = '0'
    WebMock.reset!
  end

  section_entry.destroy
  section.destroy
end
