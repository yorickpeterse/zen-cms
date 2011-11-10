require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package/comments/helper/comment_frontend')

describe('Ramaze::Helper::CommentFrontend') do
  behaves_like :capybara

  extend Ramaze::Helper::CommentFrontend

  user      = Users::Model::User[:email => 'spec@domain.tld']
  status_id = Comments::Model::CommentStatus[:name => 'open'].id
  section   = Sections::Model::Section.create(
    :name                     => 'Spec',
    :comment_allow            => true,
    :comment_require_account  => false,
    :comment_moderate         => false,
    :comment_format           => 'markdown'
  )

  entry = Sections::Model::SectionEntry.create(
    :title      => 'Spec',
    :section_id => section.id,
    :user_id    => user.id
  )

  comment_1 = Comments::Model::Comment.create(
    :user_id           => user.id,
    :comment           => 'Spec comment',
    :comment_status_id => status_id,
    :section_entry_id  => entry.id,
    :email             => user.email
  )

  comment_2 = Comments::Model::Comment.create(
    :user_id           => user.id,
    :comment           => 'Spec comment 1',
    :comment_status_id => status_id,
    :section_entry_id  => entry.id,
    :email             => user.email
  )

  should('retrieve all comments for an ID') do
    comments = get_comments(entry.slug).all

    comments.count.should                                 == 2
    comments[0].comment.include?('Spec comment').should   == true
    comments[1].comment.include?('Spec comment 1').should == true
    comments[1].user.email.should                         == 'spec@domain.tld'
    comments[1].user.name.should                          == 'Spec'
  end

  should('retrieve all comments for a slug') do
    comments = get_comments(entry.id).all

    comments.count.should                                 == 2
    comments[0].comment.include?('Spec comment').should   == true
    comments[1].comment.include?('Spec comment 1').should == true
  end

  should('retrieve all comments and check the markup') do
    comments = get_comments(entry.id).all

    comments.count.should                 == 2
    comments[0].html.strip.should == '<p>Spec comment</p>'
    comments[1].html.strip.should == '<p>Spec comment 1</p>'
  end

  should('retrieve a single comment') do
    comments = get_comments(entry.id, :limit => 1).all

    comments.count.should                               == 1
    comments[0].comment.include?('Spec comment').should == true
  end

  should('paginate a set of comments') do
    visit('/spec-comment-frontend')

    page.has_selector?('p').should         == true
    page.find('p:first-child').text.should == comment_1.comment
    page.has_selector?('.pager').should    == true

    visit('/spec-comment-frontend?page=2')

    page.has_selector?('p').should         == true
    page.find('p:first-child').text.should == comment_2.comment
    page.has_selector?('.pager').should    == true
  end

  comment_2.destroy
  comment_1.destroy
  entry.destroy
  section.destroy
end
