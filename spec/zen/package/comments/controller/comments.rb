require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('comments')
CommentsTest = {}

describe("Comments::Controller::Comments", :type => :acceptance, :auto_login => true) do
  include Comments::Controller
  include Comments::Model
  include Sections::Model

  it("Create all test data") do
    CommentsTest[:section] = Section.new(
      :name => 'Spec section', :comment_allow => true, 
      :comment_require_account => false, :comment_moderate => false, 
      :comment_format          => 'markdown'
    )
    CommentsTest[:section].save

    CommentsTest[:entry] = SectionEntry.new(
      :title => 'Spec entry', :status => 'published', :user_id => 1
    )
    CommentsTest[:entry].save
  end

  it("No comments should exist") do
    index_url = Comments.r(:index).to_s
    message   = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Create a new comment") do
    comment = Comment.new(
      :user_id => 1, :section_entry_id => CommentsTest[:entry].id, 
      :email   => 'spec@domain.tld', :comment => 'Spec comment' 
    )
    comment.save

    index_url = Comments.r(:index).to_s
    message   = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           === false
    page.has_selector?('table tbody tr').should === true
  end

  it("Edit an existing comment") do
    index_url   = Comments.r(:index).to_s
    edit_url    = Comments.r(:edit).to_s
    save_button = lang('comments.buttons.save')
    

    visit(index_url)
    click_link('Spec comment')
    
    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#comment_form') do
      fill_in('comment', :with => 'Spec comment modified')
      click_on(save_button)
    end

    page.find('textarea[name="comment"]').value.should === 'Spec comment modified'
  end

  it("Delete an existing comment") do
    index_url     = Comments.r(:index).to_s
    delete_button = lang('comments.buttons.delete')
    message       = lang('comments.messages.no_comments')

    visit(index_url)
    check('comment_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Delete all test data") do
    CommentsTest[:entry].destroy
    CommentsTest[:section].destroy
  end

end
