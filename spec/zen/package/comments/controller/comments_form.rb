require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('comments')

fixtures ['package/comments/controller/comments_form']

describe("Comments::Controller::CommentsForm") do
  behaves_like :capybara

  it('Create the test data') do
    user_id      = Users::Model::User[:name => 'Spec'].id
    entry_status = Sections::Model::SectionEntryStatus[:name => 'published'].id

    Testdata[:section] = Sections::Model::Section.create(
      :name                    => 'Spec section',
      :comment_allow           => true,
      :comment_require_account => false,
      :comment_moderate        => false,
      :comment_format          => 'plain'
    )

    Testdata[:section_entry] = Sections::Model::SectionEntry.create(
      :title                   => 'Spec entry',
      :user_id                 => user_id,
      :section_entry_status_id => entry_status,
      :section_id              => Testdata[:section].id
    )

    Testdata[:section].name.should        === 'Spec section'
    Testdata[:section_entry].title.should === 'Spec entry'

    Comments::Model::Comment.all.empty?.should === true
  end

  it('Submit a comment') do
    url = SpecCommentsForm.r(:index).to_s

    visit(url)

    # Submit the form
    within('#spec_comments_form') do
      fill_in('section_entry', :with => Testdata[:section_entry].id)
      fill_in('name'         , :with => 'Spec user')
      fill_in('website'      , :with => 'http://zen-cms.com/')
      fill_in('email'        , :with => 'spec@domain.tld')
      fill_in('comment'      , :with => 'Spec comment')

      click_on('Submit')
    end

    # Let's see if the comment exists
    comment = Comments::Model::Comment[:comment => 'Spec comment']

    comment.name.should      === 'Spec user'
    comment.comment.should   === 'Spec comment'
    comment.website.should   === 'http://zen-cms.com/'
    comment.email.should     === 'spec@domain.tld'
    comment.section_entry_id === Testdata[:section_entry].id
  end

  it('Delete the test data') do
    Comments::Model::Comment[:comment => 'Spec comment'].destroy
    Testdata[:section_entry].destroy
    Testdata[:section].destroy

    Sections::Model::Section[:name => 'Spec section'].should     === nil
    Sections::Model::SectionEntry[:title => 'Spec entry'].should === nil
  end

end
