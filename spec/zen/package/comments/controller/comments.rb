require File.expand_path('../../../../../helper', __FILE__)

describe("Comments::Controller::Comments") do
  behaves_like :capybara

  it("Create all test data") do
    @section = Sections::Model::Section.create(
      :name                    => 'Spec section',
      :comment_allow           => true,
      :comment_require_account => false,
      :comment_moderate        => false,
      :comment_format          => 'markdown'
    )

    @entry = Sections::Model::SectionEntry.create(
      :title      => 'Spec entry',
      :user_id    => 1,
      :section_id => @section.id
    )

    @section.name.should === 'Spec section'
    @entry.title.should  === 'Spec entry'
  end

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Comments::Controller::Comments.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No comments should exist") do
    index_url = Comments::Controller::Comments.r(:index).to_s
    message   = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new comment") do
    comment = Comments::Model::Comment.create(
      :user_id          => 1,
      :section_entry_id => @entry.id,
      :email            => 'spec@domain.tld',
      :comment          => 'Spec comment'
    )

    index_url = Comments::Controller::Comments.r(:index).to_s
    message   = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           === false
    page.has_selector?('table tbody tr').should === true
  end

  it("Edit an existing comment") do
    index_url   = Comments::Controller::Comments.r(:index).to_s
    edit_url    = Comments::Controller::Comments.r(:edit).to_s
    save_button = lang('comments.buttons.save')

    visit(index_url)
    click_link('Spec comment')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#comment_form') do
      fill_in('comment', :with => 'Spec comment modified')
      select(lang('comments.labels.open'), :from => 'comment_status_id')
      click_on(save_button)
    end

    page.find('textarea[name="comment"]').value \
      .should === 'Spec comment modified'

    page.find('select[name="comment_status_id"] option[selected]').text \
      .should === lang('comments.labels.open')
  end

  it("Edit an existing comment with invalid data") do
    index_url   = Comments::Controller::Comments.r(:index).to_s
    edit_url    = Comments::Controller::Comments.r(:edit).to_s
    save_button = lang('comments.buttons.save')

    visit(index_url)
    click_link('Spec comment')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#comment_form') do
      fill_in('comment', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should === true
  end

  it('Try to delete a set of comments without IDs') do
    index_url     = Comments::Controller::Comments.r(:index).to_s
    delete_button = lang('comments.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="comment_ids[]"]').should === true
  end

  it("Delete an existing comment") do
    index_url     = Comments::Controller::Comments.r(:index).to_s
    delete_button = lang('comments.buttons.delete')
    message       = lang('comments.messages.no_comments')

    visit(index_url)
    check('comment_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Delete all test data") do
    @entry.destroy
    @section.destroy

    Sections::Model::Section.filter[:name => 'Spec section'].should     === nil
    Sections::Model::SectionEntry.filter[:title => 'Spec entry'].should === nil
  end

end
