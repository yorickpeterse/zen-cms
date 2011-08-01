require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Comment') do
  behaves_like :capybara

  user_id   = Users::Model::User[:email => 'spec@domain.tld'].id
  status_id = Sections::Model::SectionEntryStatus[:name => 'published'].id
  @section  = Sections::Model::Section.create(
    :name                    => 'Comment spec section',
    :comment_allow           => false,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'markdown'
  )

  @entry = Sections::Model::SectionEntry.create(
    :title                   => 'Spec entry',
    :user_id                 => user_id,
    :section_entry_status_id => status_id,
    :section_id              => @section.id
  )

  @comment = Comments::Model::Comment.create(
    :comment          => 'Spec comment',
    :name             => 'spec',
    :email            => 'spec@domain.tld',
    :section_entry_id => @entry.id
  )

  it('Validate a valid comment') do
    url = Comments::Controller::Comments.r(:edit, @comment.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid comment') do
    visit(Comments::Controller::Comments.r(:edit, @comment.id + 100).to_s)

    current_path.should === Comments::Controller::Comments.r(:index).to_s
  end

  @comment.destroy
  @entry.destroy
  @section.destroy
end # describe
